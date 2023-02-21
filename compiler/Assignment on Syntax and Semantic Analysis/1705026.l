%option noyywrap 

%x SINGLE_LINE_STRING
%x MULTI_LINE_STRING
%x MULTI_LINE_COMMENT
%x SINGLE_LINE_COMMENT

%{
#include<iostream>
#include<stdlib.h>
#include<string.h>
#include<fstream>
#include<string>
#include<stdio.h>
#include<stdlib.h>
#include<vector>
#include"symbol_table.cpp"
#include "y.tab.h"

//#define YYSTYPE symbolInfo*

using namespace std;

//extern YYSTYPE yylval;
extern symbolTable *st;
void yyerror(char *);


int word_count=0;
int line_count=1;
int start_multi_line=0;
int start_multi_cmnt=0;
int start_single_cmnt=0;
int error_count=0;
vector<symbolInfo*> for_func_name;
string single_l_s = "";
string t_single_l_s = "";
string multi_l_s = "";
string t_multi_l_s = "";
string multi_comment = "";
string single_comment = "";
extern fstream logfile;
extern fstream errorfile;
//symbolInfo* si;

void IncWc(){
	word_count++;
}

string printKeyword(string s)
{
	for(int i=0;i<s.length();i++)
        if(s[i]>=97 && s[i]<=122)
            s[i] = s[i] - 32;
	cout<<"<"<<s<<"> "<<endl;
    return s;
	//tokenfile<<"<"<<s<<"> ";
	//cout<<"Line no "<<line_count<<": TOKEN <"<<s<<"> Lexeme "<<yytext<<" found"<<endl;
	//logfile<<"Line no "<<line_count<<": Token <"<<s<<"> Lexeme "<<yytext<<" found"<<endl;
}

void printoperator(string s)
{
	cout<<yytext<<endl;
	//tokenfile<<"<"<<s<<", "<<yytext<<"> ";
	//logfile<<"Line no "<<line_count<<": Token <"<<s<<"> Lexeme "<<yytext<<" found"<<endl;
}


%}



delim [ \t\r\f\v]
newline \n
ws [delim]+
integer {digit}+
number {digit}*(\.{digit}+)?(E[+-]?{digit}+)? 
Letter [a-zA-Z]
Ids [a-zA-Z0-9_]
DIGIT [0-9]
special_char [(\\n)(\\t)(\\')(\\a)(\\f)(\\r)(\\b)(\\v)(\\0)]

%%
[ \t\v]+ {}


"if"	{return IF;}
"for"	{return FOR;}
"do"	{return DO;}
"int"	{return INT;}
"float"	{return FLOAT;}
"void"	{return VOID;}
"switch"	{return SWITCH;}
"default"	{return DEFAULT;}
"else"	{return ELSE;}
"while"	{return WHILE;}
"break"	{return BREAK;}
"char"	{return CHAR;}
"double"	{return DOUBLE;}
"return"	{return RETURN;}
"case"	{return CASE;}
"continue"	{return CONTINUE;}
"printf"	{return PRINTLN;}
"println"	{return PRINTLN;}

"+"	{
		symbolInfo* s = new symbolInfo(yytext,"ADDOP");
        yylval.si = s;
        return ADDOP;
	}
"-"	{
		symbolInfo* s = new symbolInfo(yytext,"ADDOP");
        yylval.si = s;
        return ADDOP;
	}
"*"	{
		symbolInfo* s = new symbolInfo(yytext,"MULOP");
        yylval.si = s;
        return MULOP;
	}
"/"	{
		symbolInfo* s = new symbolInfo(yytext,"MULOP");
        yylval.si = s;
        return MULOP;
	}
"%"	{
		symbolInfo* s = new symbolInfo(yytext,"MULOP");
        yylval.si = s;
        return MULOP;
	}
"++"	{
			symbolInfo* s = new symbolInfo(yytext,"INCOP");
        	yylval.si = s;
        	return INCOP;
		}
"--"	{
			symbolInfo* s = new symbolInfo(yytext,"DECOP");
        	yylval.si = s;
        	return DECOP;
		}
"<"	{
		symbolInfo* s = new symbolInfo(yytext,"RELOP");
        yylval.si = s;
        return RELOP;
	}
">"	{
		symbolInfo* s = new symbolInfo(yytext,"RELOP");
        yylval.si = s;
        return RELOP;
	}
"="	{
		symbolInfo* s = new symbolInfo(yytext,"ASSIGNOP");
        yylval.si = s;
        return ASSIGNOP;
	}
"<="	{
			symbolInfo* s = new symbolInfo(yytext,"RELOP");
        	yylval.si = s;
        	return RELOP;
		}
">="	{
			symbolInfo* s = new symbolInfo(yytext,"RELOP");
        	yylval.si = s;
        	return RELOP;
		}
"=="	{
			symbolInfo* s = new symbolInfo(yytext,"RELOP");
        	yylval.si = s;
        	return RELOP;
		}
"!="	{
			symbolInfo* s = new symbolInfo(yytext,"RELOP");
        	yylval.si = s;
        	return RELOP;
		}
"&&"	{
			symbolInfo* s = new symbolInfo(yytext,"LOGICOP");
        	yylval.si = s;
        	return LOGICOP;
		}
"||"	{
			symbolInfo* s = new symbolInfo(yytext,"LOGICOP");
        	yylval.si = s;
        	return LOGICOP;
		}
"!"	{return NOT;}
"("	{return LPAREN;}
")"	{return RPAREN;}
"{"	{return LCURL; }
"}"	{return RCURL; }
"[" {return LTHIRD; }
"]" {return RTHIRD; }
"," {return COMMA;}
";" {return SEMICOLON;}

[a-zA-Z_]{Ids}* {
					symbolInfo* s = new symbolInfo(yytext,"ID");
                    yylval.si = s;
					for_func_name.push_back(s);
                    return ID;
				}

{DIGIT}+ 	{
				symbolInfo* s = new symbolInfo(yytext,"CONST_INT");
                yylval.si = s;
                return CONST_INT;
		 	}

{DIGIT}+(\.{DIGIT}+)?(E[+-]?{DIGIT}+)? 	{
											symbolInfo* s = new symbolInfo(yytext,"CONST_FLOAT");
                							yylval.si = s;
                							return CONST_FLOAT;
										}

{DIGIT}*(\.{DIGIT}+)?(e[+-]?{DIGIT}+)? 	{
											symbolInfo* s = new symbolInfo(yytext,"CONST_FLOAT");
                							yylval.si = s;
                							return CONST_FLOAT;
										}

{DIGIT}+(E[+-]?{DIGIT}+)\.{DIGIT}*	{
										//cout<<"in ill"<<endl;
										error_count++;
										//cout<<yytext<<endl;
										logfile<<"Error at line "<<line_count<<": Ill formed number "<<yytext<<endl<<endl;
										errorfile<<"Error at line "<<line_count<<": Ill formed number "<<yytext<<endl<<endl;
									}

{DIGIT}+(\.{DIGIT}+)(\.{DIGIT}*)+	{
										//cout<<"in tmd"<<endl;
										error_count++;
										//cout<<yytext<<endl;
										logfile<<"Error at line "<<line_count<<": Too many decimal points "<<yytext<<endl<<endl;
										errorfile<<"Error at line "<<line_count<<": Too many decimal points "<<yytext<<endl<<endl;
										char *token = strtok(yytext, ".");
										symbolInfo* s = new symbolInfo(token,"CONST_FLOAT");
                						yylval.si = s;
                						return CONST_INT;
									}									  



{DIGIT}+{Letter}+({DIGIT}|{Letter})*	{
											error_count++;
											//cout<<yytext<<endl;
											logfile<<"Error at line "<<line_count<<": Invalid prefix on ID or invalid suffix on Number "<<yytext<<endl<<endl;
											errorfile<<"Error at line "<<line_count<<": Invalid prefix on ID or invalid suffix on Number "<<yytext<<endl<<endl;
											symbolInfo* s = new symbolInfo(yytext,"ID");
											yylval.si = s;
											return ID;
										}

{DIGIT}+\.{DIGIT}*{Letter}+	{
								//cout<<"in ill3"<<endl;
								error_count++;
								//cout<<yytext<<endl;
								logfile<<"Error at line "<<line_count<<": Ill formed number "<<yytext<<endl<<endl;
								errorfile<<"Error at line "<<line_count<<": Ill formed number "<<yytext<<endl<<endl;
							}																				

[\r]	{}

<<EOF>>	{ return 0;}
[\n] {line_count++;}

. 	{
		error_count++;
		//cout<<yytext<<endl;
		logfile<<"Error at line "<<line_count<<": Unrecognized character "<<yytext<<endl<<endl;
		errorfile<<"Error at line "<<line_count<<": Unrecognized character "<<yytext<<endl<<endl;
	}

%%







