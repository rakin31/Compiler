%option noyywrap yylineno

%x SINGLE_LINE_STRING
%x MULTI_LINE_STRING
%x MULTI_LINE_COMMENT
%x SINGLE_LINE_COMMENT

%{
#include<iostream>
#include<fstream>
#include<string>
#include<stdio.h>
#include<stdlib.h>
#include"symbol_table.cpp"
using namespace std;

symbolTable* st=new symbolTable(7);
int word_count=0;
int line_count=1;
int start_multi_line=0;
int start_multi_cmnt=0;
int start_single_cmnt=0;
int error_count=0;
string single_l_s;
string t_single_l_s;
string multi_l_s;
string t_multi_l_s;
string multi_comment;
string single_comment;
fstream logfile;
fstream tokenfile;


void IncWc(){
	word_count++;
}

void printKeyword(string s)
{
	for(int i=0;i<s.length();i++)
        if(s[i]>=97 && s[i]<=122)
            s[i] = s[i] - 32;
	cout<<"<"<<s<<"> "<<endl;
	tokenfile<<"<"<<s<<"> ";
	cout<<"Line no "<<line_count<<": TOKEN <"<<s<<"> Lexeme "<<yytext<<" found"<<endl;
	logfile<<"Line no "<<line_count<<": Token <"<<s<<"> Lexeme "<<yytext<<" found"<<endl;
}

void printoperator(string s)
{
	cout<<yytext<<endl;
	tokenfile<<"<"<<s<<", "<<yytext<<"> ";
	logfile<<"Line no "<<line_count<<": Token <"<<s<<"> Lexeme "<<yytext<<" found"<<endl;
}

%}

Letter [a-zA-Z]
Ids [a-zA-Z0-9_]
DIGIT [0-9]
special_char [(\\n)(\\t)(\\')(\\a)(\\f)(\\r)(\\b)(\\v)(\\0)]

%%
[ \t\v]+ {}
"/*"	{
			cout<<"in mlc"<<endl;
			BEGIN MULTI_LINE_COMMENT;
			multi_comment = multi_comment + "/*";
			start_multi_cmnt = line_count;
		}

(\/\/)	{
			start_single_cmnt=line_count;
			single_comment = single_comment + "//";
			cout<<single_comment<<endl;
			BEGIN SINGLE_LINE_COMMENT;
		}

"if"	{printKeyword(yytext);}
"for"	{printKeyword(yytext);}
"do"	{printKeyword(yytext);}
"int"	{printKeyword(yytext);}
"float"	{printKeyword(yytext);}
"void"	{printKeyword(yytext);}
"switch"	{printKeyword(yytext);}
"default"	{printKeyword(yytext);}
"else"	{printKeyword(yytext);}
"while"	{printKeyword(yytext);}
"break"	{printKeyword(yytext);}
"char"	{printKeyword(yytext);}
"double"	{printKeyword(yytext);}
"return"	{printKeyword(yytext);}
"case"	{printKeyword(yytext);}
"continue"	{printKeyword(yytext);}

"+"	{printoperator("ADDOP");}
"-"	{printoperator("ADDOP");}
"*"	{printoperator("MULOP");}
"/"	{printoperator("MULOP");}
"%"	{printoperator("MULOP");}
"++"	{printoperator("INCOP");}
"--"	{printoperator("INCOP");}
"<"	{printoperator("RELOP");}
">"	{printoperator("RELOP");}
"="	{printoperator("ASSIGNOP");}
"<="	{printoperator("RELOP");}
">="	{printoperator("RELOP");}
"=="	{printoperator("RELOP");}
"!="	{printoperator("RELOP");}
"&&"	{printoperator("LOGICOP");}
"||"	{printoperator("LOGICOP");}
"!"	{printoperator("NOT");}
"("	{printoperator("LPAREN");}
")"	{printoperator("RPAREN");}
"{"	{printoperator("LCURL"); st->enterScope();}
"}"	{printoperator("RCURL"); st->exitScope();}
"[" {printoperator("LTHIRD");}
"]" {printoperator("RTHIRD");}
"," {printoperator("COMMA");}
";" {printoperator("SEMICOLON");}

('\\n')  {	
			cout<<yytext<<endl;
			tokenfile<<"<CHAR_CONST,\n> ";
			logfile<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found --> <CHAR_CONST, \n>"<<endl;
			if(st->insert(yytext,"CONST_CHAR"))
				st->printAST(logfile);
		}

('\\t') {	
			cout<<yytext<<endl;
			tokenfile<<"<CHAR_CONST, \t> ";
			logfile<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found --> <CHAR_CONST, \t>"<<endl;
			if(st->insert(yytext,"CONST_CHAR"))
				st->printAST(logfile);
		}

('\\\\')  	{	
				cout<<yytext<<endl;
				tokenfile<<"<CHAR_CONST, \\> ";
				logfile<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found --> <CHAR_CONST, \\\\>"<<endl;
				if(st->insert(yytext,"CONST_CHAR"))
					st->printAST(logfile);
			}

('\\'')  	{	
				cout<<yytext<<endl;
				tokenfile<<"<CHAR_CONST, '> ";
				logfile<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found --> <CHAR_CONST, "<<yytext[3]<<">"<<endl;
				if(st->insert(yytext,"CONST_CHAR"))
					st->printAST(logfile);
			}

('\\\"')  	{	
				cout<<yytext<<endl;
				tokenfile<<"<CHAR_CONST, \"> ";
				logfile<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found --> <CHAR_CONST, \""<<">"<<endl;
				if(st->insert(yytext,"CONST_CHAR"))
					st->printAST(logfile);
			}

('\\a')  	{	
				cout<<yytext<<endl;
				tokenfile<<"<CHAR_CONST,\a> ";
				logfile<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found --> <CHAR_CONST, \a>"<<endl;
				if(st->insert(yytext,"CONST_CHAR"))
					st->printAST(logfile);
			}

('\\f') 	{	
				cout<<yytext<<endl;
				tokenfile<<"<CHAR_CONST,\f> ";
				logfile<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found --> <CHAR_CONST, \f>"<<endl;
				if(st->insert(yytext,"CONST_CHAR"))
					st->printAST(logfile);
			}

('\\r')  	{	
				cout<<yytext<<endl;
				tokenfile<<"<CHAR_CONST,\r> ";
				logfile<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found --> <CHAR_CONST, \r>"<<endl;
				if(st->insert(yytext,"CONST_CHAR"))
					st->printAST(logfile);
			}

('\\b')  	{	
				cout<<yytext<<endl;
				tokenfile<<"<CHAR_CONST,\b> ";
				logfile<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found --> <CHAR_CONST, \b>"<<endl;
				if(st->insert(yytext,"CONST_CHAR"))
					st->printAST(logfile);
			}

('\\v')  	{	
				cout<<yytext<<endl;
				tokenfile<<"<CHAR_CONST,\v> ";
				logfile<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found --> <CHAR_CONST, \v>"<<endl;
				if(st->insert(yytext,"CONST_CHAR"))
					st->printAST(logfile);
			}

('\\0')  	{	
				cout<<yytext<<endl;
				tokenfile<<"<CHAR_CONST,\0> ";
				logfile<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found --> <CHAR_CONST, \n >"<<endl;
				if(st->insert(yytext,"CONST_CHAR"))
					st->printAST(logfile);
		 	}

('.(.)+')		{
					error_count++;
					cout<<yytext<<endl;
					logfile<<"Error at line no "<<line_count<<": Multi character constant error "<<yytext<<endl<<endl;
				}

('')	{
			error_count++;
			cout<<yytext<<endl;
			logfile<<"Error at line no "<<line_count<<": Empty character constant error "<<yytext<<endl<<endl;
		}

('[^\'][^\'\n\r]*((\r)?(\n)))	{
									error_count++;
									cout<<yytext<<endl;
									logfile<<"Error at line no "<<line_count<<": Unterminated character "<<yytext<<endl<<endl;
									line_count++;
								}

('\n)	{
			cout<<"in 1"<<endl;
			error_count++;
			cout<<yytext<<endl;
			logfile<<"Error at line no "<<line_count<<": Unterminated character "<<yytext<<endl<<endl;
			line_count++;
		}

('\\')	{
			error_count++;
			cout<<yytext<<endl;
			logfile<<"Error at line no "<<line_count<<": Unterminated character "<<yytext<<endl<<endl;
		}

[a-zA-Z_]{Ids}* {
					if(st->insert(yytext,"ID"))
					{
						logfile<<"Line no "<<line_count<<": Token <ID> Lexeme "<<yytext<<" found"<<endl<<endl;
						cout<<"inserted"<<endl;
						st->printAST(logfile);
					}
					else
					{
						logfile<<"Line no "<<line_count<<": Token <ID> Lexeme "<<yytext<<" found"<<endl<<endl;
						logfile<<yytext<<" already exists in current ScopeTable"<<endl<<endl;
					}
					tokenfile<<"<ID, "<<yytext<<"> ";
				}



{DIGIT}+ 	{
				cout<<yytext<<endl;
				tokenfile<<"<CONST_INT, "<<yytext<<"> ";
				logfile<<"Line no "<<line_count<<": Token <CONST_INT> Lexeme "<<yytext<<" found"<<endl;
				if(st->insert(yytext,"CONST_INT"))
					st->printAST(logfile);
		 	}

{DIGIT}+(\.{DIGIT}+)?(E[+-]?{DIGIT}+)? 	{
											cout<<yytext<<endl;
											tokenfile<<"<CONST_FLOAT, "<<yytext<<"> ";
											logfile<<"Line no "<<line_count<<": Token <CONST_FLOAT> Lexeme "<<yytext<<" found"<<endl;
											if(st->insert(yytext,"CONST_FLOAT"))
												st->printAST(logfile);
										}

{DIGIT}*(\.{DIGIT}+)?(e[+-]?{DIGIT}+)? 	{
											cout<<yytext<<endl;
											tokenfile<<"<CONST_FLOAT, "<<yytext<<"> ";
											logfile<<"Line no "<<line_count<<": Token <CONST_FLOAT> Lexeme "<<yytext<<" found"<<endl;
											if(st->insert(yytext,"CONST_FLOAT"))
												st->printAST(logfile);
										}

{DIGIT}+(E[+-]?{DIGIT}+)\.{DIGIT}*	{
										cout<<"in ill"<<endl;
										error_count++;
										cout<<yytext<<endl;
										logfile<<"Error at line no "<<line_count<<": Ill formed number "<<yytext<<endl<<endl;
									}

{DIGIT}+(\.{DIGIT}+)(\.{DIGIT}*)+	{
										cout<<"in tmd"<<endl;
										error_count++;
										cout<<yytext<<endl;
										logfile<<"Error at line no "<<line_count<<": Too many decimal points "<<yytext<<endl<<endl;
									}									  

{DIGIT}+\.[ \n\r]*	{
						cout<<"in ill_2"<<endl;
						error_count++;
						cout<<yytext<<endl;
						logfile<<"Error at line no "<<line_count<<": Ill formed number "<<yytext<<endl<<endl;
					}

{DIGIT}+{Letter}+	{
						error_count++;
						cout<<yytext<<endl;
						logfile<<"Error at line no "<<line_count<<": Invalid prefix on ID or invalid suffix on Number "<<yytext<<endl<<endl;
					}

{DIGIT}+\.{DIGIT}*{Letter}+	{
								cout<<"in ill3"<<endl;
								error_count++;
								cout<<yytext<<endl;
								logfile<<"Error at line no "<<line_count<<": Ill formed number "<<yytext<<endl<<endl;
							}

('.') 			{
					cout<<yytext[1]<<endl;
					st->insert(yytext,"CONST_CHAR");
					tokenfile<<"<CHAR_CONST, "<<yytext[1]<<"> ";
					logfile<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found --> <CHAR_CONST, "<<yytext[1]<<">"<<endl;
					st->printAST(logfile);
				}

(\") 	{
			BEGIN SINGLE_LINE_STRING;
			cout<<"in sls"<<endl;
		}

<SINGLE_LINE_STRING>\"	    {
								cout<<single_l_s<<endl;
								cout<<t_single_l_s<<endl;
								tokenfile<<"<STRING, \""<<t_single_l_s<<"\"> ";
								logfile<<"Line no "<<line_count<<": Token <STRING> Lexeme \""<<single_l_s<<"\" found --> <STRING, \""<<t_single_l_s<<"\">"<<endl;
								single_l_s="";
								t_single_l_s="";
								BEGIN INITIAL;
							}

<SINGLE_LINE_STRING>\n	{
							error_count++;
							logfile<<"Error at line no "<<line_count<<": Unterminated String \""<<single_l_s<<endl<<endl;
							line_count++;
							single_l_s = "";
							t_single_l_s = "";
							BEGIN INITIAL;
						}

<SINGLE_LINE_STRING>(\\n)	{
								cout<<"in_n"<<endl;
								single_l_s = single_l_s + "\\" + "n";
								t_single_l_s = t_single_l_s + '\n';
								cout<<t_single_l_s<<endl;
							}

<SINGLE_LINE_STRING>(\\t)	{
								cout<<"in_t"<<endl;
								single_l_s = single_l_s + "\\" + "t";
								t_single_l_s = t_single_l_s + '\t';
								cout<<t_single_l_s<<endl;
							}

<SINGLE_LINE_STRING>(\\a)	{
								cout<<"in_a"<<endl;
								single_l_s = single_l_s + "\\" + "a";
								t_single_l_s = t_single_l_s + '\a';
								cout<<t_single_l_s<<endl;
							}

<SINGLE_LINE_STRING>(\\f)	{
								cout<<"in_f"<<endl;
								single_l_s = single_l_s + "\\" + "f";
								t_single_l_s = t_single_l_s + '\f';
								cout<<t_single_l_s<<endl;
							}

<SINGLE_LINE_STRING>(\\r)	{
								cout<<"in_r"<<endl;
								single_l_s = single_l_s + "\\" + "r";
								t_single_l_s = t_single_l_s + '\r';
								cout<<t_single_l_s<<endl;
							}

<SINGLE_LINE_STRING>(\\b)	{
								cout<<"in_cot"<<endl;
								single_l_s = single_l_s + "\\" + "b";
								t_single_l_s = t_single_l_s + '\b';
								cout<<t_single_l_s<<endl;
							}

<SINGLE_LINE_STRING>(\\v)	{
								cout<<"in_v"<<endl;
								single_l_s = single_l_s + "\\" + "v";
								t_single_l_s = t_single_l_s + '\v';
								cout<<t_single_l_s<<endl;
							}

<SINGLE_LINE_STRING>(\\0)	{
								cout<<"in_O"<<endl;
								single_l_s = single_l_s + "\\" + "0";
								t_single_l_s = t_single_l_s + '\0';
								cout<<t_single_l_s<<endl;
							}

<SINGLE_LINE_STRING>(\\\")	{
								cout<<"in_t"<<endl;
								single_l_s = single_l_s + "\\" + "\"";
								t_single_l_s = t_single_l_s + '\"';
								cout<<t_single_l_s<<endl;
							}

<SINGLE_LINE_STRING>(\\')	{
								cout<<"in_sq"<<endl;
								single_l_s = single_l_s +"\\" + "'";
								t_single_l_s = t_single_l_s + '\'';
								cout<<t_single_l_s<<endl;
							}

<SINGLE_LINE_STRING>(\\)	{
								cout<<"in_bckslash"<<endl;
								single_l_s = single_l_s + "\\";
								t_single_l_s = t_single_l_s + '\\';
								cout<<t_single_l_s<<endl;
							}

<SINGLE_LINE_STRING>(\\(\r)?(\n))	{
										BEGIN MULTI_LINE_STRING;
										start_multi_line = line_count;
										multi_l_s = single_l_s + "\\" + '\n';
										t_multi_l_s = t_single_l_s;
										single_l_s = "";
										t_single_l_s = "";
										line_count++;
									}

<SINGLE_LINE_STRING>[^\n\"\\]*				{
												cout<<yytext<<endl;
												single_l_s = single_l_s + yytext;
												t_single_l_s = t_single_l_s + yytext;
											}

<MULTI_LINE_STRING><<EOF>>	{
								error_count++;
								logfile<<"Error at line no "<<start_multi_line<<": Unterminated string "<<multi_l_s<<endl<<endl;
								st->printAST(logfile);
								logfile<<"Total lines: "<<line_count<<endl<<"Total errors: "<<error_count; 
								return 0;
							}

<MULTI_LINE_STRING>(\\\")	{
								cout<<"in_mtt"<<endl;
								multi_l_s = multi_l_s + "\\" + "\"";
								t_multi_l_s = t_multi_l_s + "\"";
								cout<<t_multi_l_s<<endl;
							}

<MULTI_LINE_STRING>(\\n)	{
								cout<<"in_mtt_n"<<endl;
								multi_l_s = multi_l_s + "\\" + "n";
								t_multi_l_s = t_multi_l_s + '\n';
								cout<<t_multi_l_s<<endl;
							}

<MULTI_LINE_STRING>(\\')	{
								cout<<"in_mlsq"<<endl;
								multi_l_s = multi_l_s + "\'";
								t_multi_l_s = t_multi_l_s + '\'';
								cout<<t_multi_l_s<<endl;
							}

<MULTI_LINE_STRING>(\\)		{
								cout<<"in_mtt_t"<<endl;
								multi_l_s = multi_l_s + "\\";
								t_multi_l_s = t_multi_l_s + '\\';
								cout<<t_multi_l_s<<endl;
							}

<MULTI_LINE_STRING>(\\a)	{
								cout<<"in_mtt_a"<<endl;
								multi_l_s = multi_l_s + "\\" + "a";
								t_multi_l_s = t_multi_l_s + '\a';
								cout<<t_multi_l_s<<endl;
							}

<MULTI_LINE_STRING>(\\f)	{
								cout<<"in_mtt_f"<<endl;
								multi_l_s = multi_l_s + "\\" + "f";
								t_multi_l_s = t_multi_l_s + '\f';
								cout<<t_multi_l_s<<endl;
							}

<MULTI_LINE_STRING>(\\r)	{
								cout<<"in_mtt_r"<<endl;
								multi_l_s = multi_l_s + "\\" + "r";
								t_multi_l_s = t_multi_l_s + '\r';
								cout<<t_multi_l_s<<endl;
							}

<MULTI_LINE_STRING>(\\b)	{
								cout<<"in_mtt_b"<<endl;
								multi_l_s = multi_l_s + "\\" + "b";
								t_multi_l_s = t_multi_l_s + '\b';
								cout<<t_multi_l_s<<endl;
							}

<MULTI_LINE_STRING>(\\v)	{
								cout<<"in_mtt_v"<<endl;
								multi_l_s = multi_l_s + "\\" + "v";
								t_multi_l_s = t_multi_l_s + '\v';
								cout<<t_multi_l_s<<endl;
							}							

<MULTI_LINE_STRING>(\\0)	{
								cout<<"in_mtt_O"<<endl;
								multi_l_s = multi_l_s + "\\" + "0";
								t_multi_l_s = t_multi_l_s + '\0';
								cout<<t_multi_l_s<<endl;
							}

<MULTI_LINE_STRING>(\\t)	{
								cout<<"in_mtt_t"<<endl;
								multi_l_s = multi_l_s + "\\" + "t";
								t_multi_l_s = t_multi_l_s + '\t';
								cout<<t_multi_l_s<<endl;
							}							

<MULTI_LINE_STRING>(\\(\r)?(\n))	{
										line_count++;
										multi_l_s = multi_l_s + "\\" + '\n';
									}

<MULTI_LINE_STRING>[\n]		{
								cout<<"in mls"<<endl; 
								line_count++;
								error_count++; 
								logfile<<"Error at line no "<<start_multi_line<<": Unterminated String \""<<multi_l_s<<endl<<endl;
								BEGIN INITIAL;
							}

<MULTI_LINE_STRING>[^\n\"\\]*		{
										cout<<"in mls"<<endl;
										cout<<yytext<<endl;
										multi_l_s = multi_l_s + yytext;
										t_multi_l_s = t_multi_l_s + yytext;
										cout<<multi_l_s<<endl;
									}

<MULTI_LINE_STRING>\"	{
							cout<<multi_l_s<<endl;
							logfile<<"Line no "<<start_multi_line<<": Token <STRING> Lexeme \""<<multi_l_s<<"\" found --> <STRING, \""<<t_multi_l_s<<"\">"<<endl;
							tokenfile<<"<STRING, \""<<t_multi_l_s<<"\"> ";
							multi_l_s = "";
							BEGIN INITIAL;
						}

<MULTI_LINE_COMMENT><<EOF>>	{
								error_count++;
								logfile<<"Error at line no "<<start_multi_cmnt<<": Unterminated Comment "<<multi_comment<<endl<<endl;
								st->printAST(logfile);
								logfile<<"Total lines: "<<line_count<<endl<<"Total errors: "<<error_count; 
								return 0;
							}

<MULTI_LINE_COMMENT>[^(\n)|(\*\/)]* 	{cout<<yytext<<endl; multi_comment = multi_comment + yytext; cout<<multi_comment<<endl;}

<MULTI_LINE_COMMENT>[\n]	{line_count++; multi_comment = multi_comment + '\n';} 
<MULTI_LINE_COMMENT>(\*\/)		{
									multi_comment = multi_comment + "*/";
									cout<<multi_comment<<endl;
									logfile<<"Line no "<<start_multi_cmnt<<": Token <COMMENT> Lexeme "<<multi_comment<<" found"<<endl;
									multi_comment = "";
									BEGIN INITIAL;
								}

<MULTI_LINE_COMMENT>"*"	{cout<<yytext<<"in mlcc"<<endl;	multi_comment = multi_comment + yytext;}
<MULTI_LINE_COMMENT>"/"	{cout<<yytext<<"in mlcc"<<endl;	multi_comment = multi_comment + yytext;}
<SINGLE_LINE_COMMENT>"/"	{cout<<yytext<<"in slcc"<<endl;	multi_comment = multi_comment + yytext;}
<SINGLE_LINE_COMMENT>(\\(\r)?(\n)) 	{
										single_comment = single_comment + "\\" + '\n';
										line_count++;
									}

<SINGLE_LINE_COMMENT>(\\) 	{
								single_comment = single_comment + "\\";
							}

<SINGLE_LINE_COMMENT>[^\n\\]*	{
									cout<<"in slc"<<endl;
									cout<<yytext<<endl;
									single_comment = single_comment + yytext;
									cout<<single_comment<<endl;
								}

<SINGLE_LINE_COMMENT>[\n]		{
									line_count++;
									logfile<<"Line no "<<start_single_cmnt<<": Token <COMMENT> Lexeme "<<single_comment<<" found"<<endl;
									single_comment = "";
									BEGIN INITIAL;
								}

[\r]	{}

[\n] {line_count++; cout<<line_count<<endl;}
<<EOF>> {
			st->printAST(logfile);
			printf("Total Line Number: %d and word number: %d\n",line_count,word_count);
			logfile<<"Total lines: "<<line_count<<endl<<"Total errors: "<<error_count; 
			return 0;
		}
. 	{
		error_count++;
		cout<<yytext<<endl;
		logfile<<"Error at line no "<<line_count<<": Unrecognized character "<<yytext<<endl<<endl;
	}
%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	//fstream f1;
    logfile.open("1705026_log.txt",ios::out);
	tokenfile.open("1705026_token.txt",ios::out);

	yyin= fin;
	yylineno = 1;
	single_l_s="";
	t_single_l_s = "";
	multi_l_s="";
	t_multi_l_s = "";
	multi_comment = "";
	single_comment = "";
	yylex();
	fclose(yyin);
	logfile.close();
	tokenfile.close();
	return 0;
}
