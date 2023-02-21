%{
#include<iostream>
#include <bits/stdc++.h>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<fstream>
#include<string>
#include<vector>
#include"symbol_table.cpp"

//#define YYSTYPE symbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
int sc_count = 0;
extern FILE *yyin;
extern int line_count;
extern int error_count;
extern vector<symbolInfo*> for_func_name;
int labelCount=0;
int tempCount=0;

int in_func = 0;
bool ty_mismatch = false;
string my_newline = "\n";
string my_tab = "\t";
string curr_func_name ="";
symbolTable *table;
symbolInfo* my_si;
symbolInfo* my_si_2;
vector<symbolInfo*> return_type;
vector<symbolInfo*> vec_var;
vector<symbolInfo*> my_var;
vector<symbolInfo*> parameters;
vector<string> parameters_asm;
vector<string> func_var;
vector<symbolInfo*> my_arguments;
vector<string> arg_asm;
vector<string> my_parameters;
vector<string> data_seg; 
fstream logfile;
fstream errorfile;
fstream codefile;
fstream o_codefile;

string give_word(string s)
{
    string s1="";
    int i=0;
    while(s[i] != '\0')
    {
        if (s[i] == ',')
            break;
        else
            s1 = s1 + s[i];
        i++;
    }
    return s1;
}

void gen_optimized_file()
{
	int flag = 0;
    //fstream codefile;
    codefile.open("code.asm",ios::in);

    string my_word_1="";
    string my_word_2="";
    string my_word_3="";
    string my_word_4="";
    string my_word_5="";
    string my_word_6="";
    string line;
    string o_line="";
    while(codefile)
    {
        getline(codefile,line);
        if(line == "-1")
            break;
        //cout<<line<<endl;
        istringstream ss(line);
        string word;
        while (ss >> word)
        {
            //cout<<"in loop"<<endl;
            if (word == "MOV")
            {
                ss>>my_word_1;
                my_word_1 = give_word(my_word_1);
                ss>>my_word_2;
                //ss>>my_word_3;
                //cout<<my_word_1<<" 1_ "<<my_word_2<<" 2_ "<<endl;
                o_line = o_line + line + "\n";
                getline(codefile,line);
                istringstream ss(line);
                ss >> word;
                //cout<<word<<" w"<<endl;
                if(word == ";Line")
                {
                    o_line = o_line + line + "\n";
                    getline(codefile,line);
                    o_line = o_line + line + "\n";
                    getline(codefile,line);
                    //cout<<line<<"    my_line"<<endl;
                    istringstream ss(line);
                    ss >> word;
                    //cout<<word<<" wif"<<endl;
                    if (word == "MOV")
                    {
                        ss>>my_word_4;
                        my_word_4 = give_word(my_word_4);
                        ss>>my_word_5;
                        //cout<<my_word_4<<" 4_ "<<my_word_5<<" 5_ "<<endl;
                        //ss>>my_word_6;
                        if((my_word_1 == my_word_5) && (my_word_2 == my_word_4) )
                        {
                            //cout<<"here"<<endl;
                            getline(codefile,line);
                            o_line = o_line + line + "\n";
                            flag = 1;
                            break;
                        }
                        else
                        {
                            o_line = o_line + line + "\n";
                            flag = 1;
                            break;
                        }
                    }
                    else
                    {
                        o_line = o_line + line + "\n";
                        flag = 1;
                        break;
                    }

                }
				else if (word == "ADD")
                {
                    ss>>my_word_1;
                    my_word_1 = give_word(my_word_1);
                    ss>>my_word_2;
                    if(my_word_2 == "0")
                    {
                        //getline(codefile,line);
                        //o_line = o_line + line + "\n";
                        flag = 1;
                        break;
                    }
					else
					{
						o_line = o_line + line + "\n";
                        flag = 1;
                        break;
					}
                }
                else
                {
                    o_line = o_line + line + "\n";
                    flag = 1;
                    break;
                }

            }
            else
            {
                flag = 0;
                break;
            }

        }
        if (flag == 0)
            o_line = o_line + line + "\n";
    }

    fstream o_codefile;
    o_codefile.open("optimized_code.asm",ios::out);
    o_codefile<<o_line<<endl;
    cout<<o_line<<endl;
    codefile.close();
	o_codefile.close();
}

string newLabel()
{
	string lb = "L";
	string lc;
	lc = to_string(labelCount);
	labelCount++;
	lb = lb + lc;
	return lb;
}

string newTemp()
{
	string t= "t";
	string tc;
	tc = to_string(tempCount);
	tempCount++;
	t = t + tc;
	return t;
}

void yyerror(char *s)
{
	//write your code
	error_count++;
	errorfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
}



%}

%union{
	int ival;
	symbolInfo* si;
}



%token IF FOR DO INT FLOAT VOID SWITCH DEFAULT ELSE WHILE BREAK CHAR DOUBLE RETURN CASE CONTINUE SEMICOLON COMMA LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD PRINTLN NOT
%token <si> ID ADDOP ASSIGNOP LOGICOP RELOP MULOP CONST_INT CONST_FLOAT INCOP DECOP
%type <si> type_specifier var_declaration func_declaration func_definition declaration_list parameter_list unit program start variable factor unary_expression term simple_expression rel_expression logic_expression expression statement statements compound_statement expression_statement argument_list arguments


//%left 
//%right

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
					{
						//write your code in this block in all the similar blocks below
						$$ = $1;
						cout<<"opended"<<endl;
						logfile<<"Line "<<line_count<<": start : program"<<endl<<endl<<endl<<endl;
						table->printAST(logfile);
						
						logfile<<"Total lines: "<<line_count<<endl;
						logfile<<"Total errors: "<<error_count<<endl<<endl;
						
						cout<<newLabel()<<endl<<newLabel()<<endl;
						cout<<newTemp()<<endl<<newTemp()<<endl;
						if (error_count == 0)
						{
							string asm_code = ".MODEL SMALL" + my_newline + my_newline + ".STACK 100H" + my_newline + my_newline + ".DATA" + my_newline;
							asm_code = asm_code + my_tab + "CR EQU 0DH" + my_newline + my_tab + "LF EQU 0AH" + my_newline + my_newline;
							for(int i =0; i<data_seg.size(); i++)
							{
								asm_code = asm_code + my_tab + data_seg[i] + my_newline;
							}
							asm_code = asm_code + my_tab + "ADDRESS DW ?" + my_newline + my_newline;
							asm_code = asm_code + ".CODE" + my_newline + my_newline;
							asm_code = asm_code + $1->getCode(); 

							asm_code = asm_code + "OUT_NUM PROC" + my_newline + my_newline;
							asm_code = asm_code + my_tab + "POP ADDRESS" + my_newline + my_tab + "POP BX" + my_newline + my_tab + "CMP BX, 0" + my_newline + my_tab + "JL FOR_NEG"  + my_newline + my_tab + "JMP FOR_NUM" + my_newline + my_newline;
							asm_code = asm_code + "FOR_NEG:" + my_newline + my_tab + "MOV AH, 2" + my_newline + my_tab + "MOV DL, '-'" + my_newline + my_tab + "INT 21H" + my_newline + my_tab + "NEG BX" + my_newline + my_newline;
							asm_code = asm_code + "FOR_NUM:" + my_newline + my_tab + "XOR AX, AX" + my_newline + my_tab + "XOR CX, CX" + my_newline + my_tab + "MOV AX, BX" + my_newline + my_tab + "MOV BX, 10" + my_newline + my_newline;
							asm_code = asm_code + "CNV_D:" + my_newline + my_tab + "XOR DX, DX" + my_newline + my_tab + "DIV BX" + my_newline + my_tab + "PUSH DX" + my_newline + my_tab + "INC CX" + my_newline + my_tab + "OR AX, AX" + my_newline + my_tab + "JNE CNV_D" + my_newline + my_newline;
							asm_code = asm_code + "PRINT:" + my_newline + my_tab + "MOV AH, 2" + my_newline + my_tab + "POP DX" + my_newline + my_tab + "OR DL, 30H" + my_newline + my_tab + "INT 21H" + my_newline + my_tab + "LOOP PRINT" + my_newline + my_newline; 
							asm_code = asm_code + "RETURN1:" + my_newline + my_tab + "MOV DL, CR" + my_newline + my_tab + "INT 21H" + my_newline + my_tab + "MOV DL, LF" + my_newline + my_tab + "INT 21H" + my_newline + my_tab + "PUSH ADDRESS" + my_newline + my_tab + "RET" + my_newline + my_newline;
							asm_code = asm_code + "OUT_NUM ENDP" + my_newline + my_newline + my_newline;
							asm_code = asm_code + my_tab + "END MAIN" + my_newline;
							$$->setCode(asm_code);
							codefile<<$$->getCode()<<endl;
							codefile.close();
							gen_optimized_file();
							//o_codefile<<$$->getCode()<<endl;
							//codefile<<
						}
					}
					
	;

program : program unit 	
						{
							$$ = new symbolInfo($1->getName() + '\n' + $2->getName(),"non_terminal");
							logfile<<"Line "<<line_count<<": program : program unit"<<endl<<endl;
							//logfile<<$$->getName()<<endl;
							logfile<<$$->getName()<<endl<<endl<<endl;
							$$->setCode($1->getCode() + my_newline + $2->getCode());
							cout<<"At line no: "<<line_count<<" program : program unit"<<endl<<endl;
							//cout<<$$->getName()<<endl;
							cout<<$$->getName()<<endl<<endl;
						}
	| unit				
						{
							$$ = $1;
							//cout<<"unit"<<endl;
							logfile<<"Line "<<line_count<<": program : unit"<<endl<<endl;
							logfile<<$1->getName()<<endl<<endl<<endl;
							cout<<"At line no: "<<line_count<<" program : unit"<<endl<<endl;
							cout<<$1->getName()<<endl<<endl;
						}
						
	;
	
unit : var_declaration	
							{
								logfile<<"Line "<<line_count<<": unit : var_declaration"<<endl<<endl;
								logfile<<$1->getName()<<endl<<endl<<endl;
								$$ = $1; 
								//cout<<"var_declaration"<<endl;
								//cout<<$1->getName()<<endl;
								cout<<"At line no: "<<line_count<<" unit : var_declaration"<<endl<<endl;
								cout<<$1->getName()<<endl<<endl;
							}

	 | func_declaration
	 						{
								logfile<<"Line "<<line_count<<": unit : func_declaration"<<endl<<endl;
								logfile<<$1->getName()<<endl<<endl<<endl;
								$$ = $1; 
								//cout<<"var_declaration"<<endl;
								//cout<<$1->getName()<<endl;
								cout<<"At line no: "<<line_count<<" unit : func_declaration"<<endl<<endl;
								cout<<$1->getName()<<endl<<endl;

							}

	 | func_definition
	 						{
								logfile<<"Line "<<line_count<<": unit : func_definition"<<endl<<endl;
								logfile<<$1->getName()<<endl<<endl<<endl;
								$$ = $1; 
								//cout<<"var_declaration"<<endl;
								//cout<<$1->getName()<<endl;
								cout<<"At line no: "<<line_count<<" unit : func_definition"<<endl<<endl;
								cout<<$1->getName()<<endl<<endl;
							}
     ;
     
				

func_declaration : type_specifier ID LPAREN parameter_list RPAREN dummy_state_three SEMICOLON
																{
																	my_si = table->lookup($2->getName());
																	if (my_si != NULL)
																	{
																		error_count++;
																		logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl<<endl;
																		errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl<<endl;
																	}
																	table->insert($2->getName(),$2->getType(),"function",$1->getName(),my_parameters);
																	/*my_si = table->lookup($2->getName());
																	errorfile<<my_si->getName()<<endl;
																	for ( int i=0; i<my_si->getFunc_parameters().size(); i++)
																		errorfile<<my_si->getFunc_parameters()[i]<<endl;
																	errorfile<<endl;*/
																	for_func_name.clear();
																	parameters.clear();
																	//table->printAST(logfile);
																	logfile<<"Line "<<line_count<<": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl<<endl;
																	$$ = new symbolInfo($1->getName()+ " " + $2->getName() + "(" + $4->getName() +")" + ";","non_terminal"); 
																	logfile<<$$->getName()<<endl<<endl<<endl;
																	//cout<<"var_declaration"<<endl;
																	//cout<<$1->getName()<<endl;
																	cout<<"At line no: "<<line_count<<" func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl<<endl;
																	cout<<$$->getName()<<endl<<endl;
																	return_type.clear();
																	my_parameters.clear();
																}

		| type_specifier ID LPAREN RPAREN dummy_state_three SEMICOLON
																{
																	my_si = table->lookup($2->getName());
																	if (my_si != NULL)
																	{
																		error_count++;
																		logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl<<endl;
																		errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl<<endl;
																	}
																	table->insert($2->getName(),$2->getType(),"function",$1->getName(),my_parameters);
																	for_func_name.clear();
																	//table->printAST(logfile);
																	logfile<<"Line "<<line_count<<": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl<<endl;
																	$$ = new symbolInfo($1->getName()+ " " + $2->getName() + "(" + ")" + ";","non_terminal"); 
																	logfile<<$$->getName()<<endl<<endl<<endl;
																	//cout<<"var_declaration"<<endl;
																	//cout<<$1->getName()<<endl;
																	cout<<"At line no: "<<line_count<<" func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl<<endl;
																	cout<<$$->getName()<<endl<<endl;
																	return_type.clear();
																	my_parameters.clear();
																}

		| type_specifier ID LPAREN parameter_list RPAREN dummy_state_three error
																					{
																						my_si = table->lookup($2->getName());
																						if (my_si != NULL)
																						{
																							error_count++;
																							logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl<<endl;
																							errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl<<endl;
																						}
																						table->insert($2->getName(),$2->getType(),"function",$1->getName(),my_parameters);
																						/*my_si = table->lookup($2->getName());
																						errorfile<<my_si->getName()<<endl;
																						for ( int i=0; i<my_si->getFunc_parameters().size(); i++)
																							errorfile<<my_si->getFunc_parameters()[i]<<endl;
																						errorfile<<endl;*/
																						for_func_name.clear();
																						parameters.clear();
																						//table->printAST(logfile);
																						logfile<<"Line "<<line_count<<": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl<<endl;
																						$$ = new symbolInfo($1->getName()+ " " + $2->getName() + "(" + $4->getName() +")" + ";","non_terminal"); 
																						logfile<<$$->getName()<<endl<<endl<<endl;
																						logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
																						//cout<<"var_declaration"<<endl;
																						//cout<<$1->getName()<<endl;
																						cout<<"At line no: "<<line_count<<" func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl<<endl;
																						cout<<$$->getName()<<endl<<endl;
																						return_type.clear();
																						my_parameters.clear();
																					}		

		| type_specifier ID LPAREN RPAREN dummy_state_three error
																{
																	my_si = table->lookup($2->getName());
																	if (my_si != NULL)
																	{
																		error_count++;
																		logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl<<endl;
																		errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl<<endl;
																	}
																	table->insert($2->getName(),$2->getType(),"function",$1->getName(),my_parameters);
																	for_func_name.clear();
																	//table->printAST(logfile);
																	logfile<<"Line "<<line_count<<": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl<<endl;
																	$$ = new symbolInfo($1->getName()+ " " + $2->getName() + "(" + ")" + ";","non_terminal"); 
																	logfile<<$$->getName()<<endl<<endl<<endl;
																	logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
																	//cout<<"var_declaration"<<endl;
																	//cout<<$1->getName()<<endl;
																	cout<<"At line no: "<<line_count<<" func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl<<endl;
																	cout<<$$->getName()<<endl<<endl;
																	return_type.clear();
																	my_parameters.clear();
																}	

		| type_specifier ID LPAREN error RPAREN dummy_state_three SEMICOLON
																			{
																				my_si = table->lookup($2->getName());
																				if (my_si != NULL)
																				{
																					error_count++;
																					logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl<<endl;
																					errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl<<endl;
																				}
																				table->insert($2->getName(),$2->getType(),"function",$1->getName(),my_parameters);
																				for_func_name.clear();
																				//table->printAST(logfile);
																				logfile<<"Line "<<line_count<<": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl<<endl;
																				$$ = new symbolInfo($1->getName()+ " " + $2->getName() + "(" + ")" + ";","non_terminal"); 
																				logfile<<$$->getName()<<endl<<endl<<endl;
																				logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
																				//cout<<"var_declaration"<<endl;
																				//cout<<$1->getName()<<endl;
																				cout<<"At line no: "<<line_count<<" func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl<<endl;
																				cout<<$$->getName()<<endl<<endl;
																				return_type.clear();
																				my_parameters.clear();
																			}
		;

dummy_state_three :
					{
						table->enterScope();
						//logfile<<"New ScopeTable with id "<<table->giveid()<<" created"<<endl<<endl;
						//cout<<"New ScopeTable with id "<<table->giveid()<<" created"<<endl<<endl;

						//logfile<<"ScopeTable with id "<<table->giveid()<<" removed"<<endl<<endl;
						//cout<<"ScopeTable with id "<<table->giveid()<<" removed"<<endl<<endl;
						table->exitScope();
					}



func_definition : type_specifier ID LPAREN parameter_list RPAREN  dummy_state compound_statement
																						{
																							//table->insert($2->getName(),$2->getType());
																							//table->printAST(logfile);
																							string my_code = "";
																							for_func_name.clear();
																							logfile<<"Line "<<line_count<<": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl<<endl;
																							$$ = new symbolInfo($1->getName()+ " " + $2->getName() + "(" + $4->getName() + ")" + $7->getName(),"non_terminal"); 
																							logfile<<$$->getName()<<endl<<endl;
																							string push_reg = my_tab + "PUSH AX" + my_newline + my_tab + "PUSH BX" + my_newline + my_tab + "PUSH CX" + my_newline + my_tab + "PUSH DX" + my_newline + my_tab + "PUSH DI" + my_newline + my_tab + "PUSH BP" + my_newline; 
																							if ($2->getName() == "main")
																							{
																								my_code = "MAIN PROC" + my_newline + my_tab + "MOV AX, @DATA" + my_newline + my_tab + "MOV DS, AX";
																								my_code = my_code + my_newline + my_tab + $7->getCode() + my_newline;
																								my_code = my_code + my_newline + my_newline + my_tab + "MOV AH, 4CH" + my_newline + my_tab + "INT 21H" + my_newline + my_newline;
																								my_code = my_code + "MAIN ENDP" + my_newline + my_newline + my_newline;
																							}
																							else if ($2->getName() != "main")
																							{
																								data_seg.push_back("ADDRESS_" + to_string(sc_count) + " DW ?");
																								my_code = $2->getName() + " PROC" + my_newline + my_tab + "POP ADDRESS_" + to_string(sc_count) + my_newline;
																								my_code = my_code + push_reg + my_tab + "MOV BP, SP" + my_newline;
																								if(parameters_asm.size() != 0)
																								{
																									int add_num = 12;
																									for(int i =parameters_asm.size()-1; i>=0; i--)
																									{
																										string t = newTemp();
																										string t_data = t + " DW ?";
																										data_seg.push_back(t_data);
																										my_code = my_code + my_tab + "MOV AX, [BP+" + to_string(add_num) + "]" + my_newline + my_tab + "MOV " + parameters_asm[i] + ", AX" + my_newline;
																										add_num = add_num + 2; 
																									}
																								}
																								parameters_asm.clear();
																								if ($1->getName() == "void")
																								{
																									my_code = my_code + $7->getCode() + my_newline + my_tab + "PUSH ADDRESS_" + to_string(sc_count) + my_newline + my_tab + "RET" + my_newline + my_newline + $2->getName() + " ENDP" + my_newline + my_newline;
																								}
																								else
																								{
																									my_code = my_code + $7->getCode() + my_newline + $2->getName() + " ENDP" + my_newline + my_newline;
																								}
																							}
																							$$->setCode(my_code);
																							//cout<<"var_declaration"<<endl;
																							//cout<<$1->getName()<<endl;
																							cout<<"At line no: "<<line_count<<" func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl<<endl;
																							cout<<$$->getName()<<endl<<endl;
																							my_parameters.clear();
																						}

		| type_specifier ID LPAREN RPAREN dummy_state compound_statement
																{
																	//table->insert($2->getName(),$2->getType());
																	//table->printAST(logfile);	
																	string my_code = "";	
																	for_func_name.clear();																
																	logfile<<"Line "<<line_count<<": func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl<<endl;
																	$$ = new symbolInfo($1->getName()+ " " + $2->getName() + "(" + ")" + $6->getName(),"non_terminal"); 
																	logfile<<$$->getName()<<endl<<endl;

																	string push_reg = my_tab + "PUSH AX" + my_newline + my_tab + "PUSH BX" + my_newline + my_tab + "PUSH CX" + my_newline + my_tab + "PUSH DX" + my_newline + my_tab + "PUSH DI" + my_newline + my_tab + "PUSH BP" + my_newline; 
																	if ($2->getName() == "main")
																	{
																		my_code = "MAIN PROC" + my_newline + my_tab + "MOV AX, @DATA" + my_newline + my_tab + "MOV DS, AX";
																		my_code = my_code + my_newline + my_tab + $6->getCode() + my_newline;
																		my_code = my_code + my_newline + my_newline + my_tab + "MOV AH, 4CH" + my_newline + my_tab + "INT 21H" + my_newline + my_newline;
																		my_code = my_code + "MAIN ENDP" + my_newline + my_newline + my_newline;
																	}
																	else if ($2->getName() != "main")
																	{
																		data_seg.push_back("ADDRESS_" + to_string(sc_count) + " DW ?");
																		my_code = $2->getName() + " PROC" + my_newline + my_tab + "POP ADDRESS_" + to_string(sc_count) + my_newline;
																		my_code = my_code + push_reg + my_tab + "MOV BP, SP" + my_newline;
																		parameters_asm.clear();
																		if ($1->getName() == "void")
																		{
																			my_code = my_code + $6->getCode() + my_newline + my_tab + "PUSH ADDRESS_" + to_string(sc_count) + my_newline + my_tab + "RET" + my_newline + my_newline + $2->getName() + " ENDP" + my_newline + my_newline;
																		}
																		else
																		{
																			my_code = my_code + $6->getCode() + my_newline + $2->getName() + " ENDP" + my_newline + my_newline;
																		}
																	}
																	$$->setCode(my_code);
																	//cout<<"var_declaration"<<endl;
																	//cout<<$1->getName()<<endl;
																	cout<<"At line no: "<<line_count<<" func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl<<endl;
																	cout<<$$->getName()<<endl<<endl;
																	my_parameters.clear();
																}

		| type_specifier ID LPAREN error RPAREN dummy_state compound_statement
																				{
																					//table->insert($2->getName(),$2->getType());
																					//table->printAST(logfile);		
																					for_func_name.clear();																
																					logfile<<"Line "<<line_count<<": func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl<<endl;
																					$$ = new symbolInfo($1->getName()+ " " + $2->getName() + "(" + ")" + $7->getName(),"non_terminal"); 
																					logfile<<$$->getName()<<endl<<endl;
																					logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
																					//cout<<"var_declaration"<<endl;
																					//cout<<$1->getName()<<endl;
																					cout<<"At line no: "<<line_count<<" func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl<<endl;
																					cout<<$$->getName()<<endl<<endl;
																					my_parameters.clear();
																				}	

 		;

dummy_state :
				{
					in_func = 1;
					if( for_func_name.size() != 0)
					{
						my_si = table->lookup(for_func_name[0]->getName());
						curr_func_name = for_func_name[0]->getName();
						if (my_si != NULL && my_si->getDefined() == false)
						{
							table->lookup(for_func_name[0]->getName())->setDefined(true);
							if (my_si->getVar_type() == "function" && my_si->getFunc_parameters().size() != my_parameters.size())
							{
								error_count++;
								errorfile<<"Error at line "<<line_count<<": Total number of arguments mismatch with declaration in function "<<my_si->getName()<<endl<<endl;
								logfile<<"Error at line "<<line_count<<": Total number of arguments mismatch with declaration in function "<<my_si->getName()<<endl<<endl;
							}
							
							if (my_si->getVar_type() == "function" && my_si->getFunc_parameters().size() == my_parameters.size())
							{
								for(int i =0; i< my_si->getFunc_parameters().size(); i++)
								{
									if (my_si->getFunc_parameters()[i] != my_parameters[i])
									{
										error_count++;
										errorfile<<"Error at line "<<line_count<<": "<<i+1<<"th parameter type mismatch with function declaration of function "<<my_si->getName()<<endl<<endl;
										logfile<<"Error at line "<<line_count<<": "<<i+1<<"th parameter type mismatch with function declaration of function "<<my_si->getName()<<endl<<endl;
										break;
									}
								}
							}

							if(my_si->getFunc_return_type() != return_type[0]->getName() && my_si->getVar_type() == "function")
							{
								error_count++;
								errorfile<<"Error at line "<<line_count<<": Return type mismatch with function declaration in function "<<my_si->getName()<<endl<<endl;
								logfile<<"Error at line "<<line_count<<": Return type mismatch with function declaration in function "<<my_si->getName()<<endl<<endl;
							}
							else if (my_si->getVar_type() != "function")
							{
								error_count++;
								errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<my_si->getName()<<endl<<endl;
								logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<my_si->getName()<<endl<<endl;
							}
						}
						else if (my_si != NULL && my_si->getDefined() == true)
						{
							error_count++;
							logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<my_si->getName()<<endl<<endl;
							errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<my_si->getName()<<endl<<endl;
						}
						table->insert(for_func_name[0]->getName(),for_func_name[0]->getType(),"function",return_type[0]->getName(),my_parameters,true);
						for_func_name.clear();
					}
					/*errorfile<<"printing type"<<endl;
					for(int i =0;i<return_type.size(); i++)
						errorfile<<return_type[i]->getName()<<endl;
					errorfile<<"end of primting"<<endl;*/
					table->enterScope();
					sc_count++;
					//logfile<<"New ScopeTable with id "<<table->giveid()<<" created"<<endl<<endl;
					cout<<"New ScopeTable with id "<<table->giveid()<<" created"<<endl<<endl;

					if( parameters.size() != 0)
					{
						vector<string> v;
						for (int i = 0; i < parameters.size(); i++ )
						{
							table->insert(parameters[i]->getName(),parameters[i]->getType(),parameters[i]->getVar_type(),"",v,false,"",parameters[i]->getAsm_var());
							parameters_asm.push_back(parameters[i]->getName() + parameters[i]->getAsm_var());
						}
						parameters.clear();
						for_func_name.clear();
					}
					return_type.clear();
					my_parameters.clear();
				}

parameter_list  : parameter_list COMMA type_specifier ID
															{
																$4->setVar_type($3->getName());
																$4->setAsm_var("_" + to_string(sc_count+1));
																string s = $4->getName() + "_" + to_string(sc_count+1) + " DW ?";
													 			data_seg.push_back(s);
																parameters.push_back($4);
																my_parameters.push_back($3->getName());
																if (parameters.size() != 0)
																{
																	for (int i=0; i<parameters.size(); i++)
																	{
																		for(int j = i+1; j <parameters.size(); j++)
																		{
																			if (parameters[i]->getName() == parameters[j]->getName())
																			{
																				parameters.pop_back();
																				error_count++;
																				errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<parameters[i]->getName()<<" in parameter"<<endl<<endl;
																				logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<parameters[i]->getName()<<" in parameter"<<endl<<endl;
																			}
																		}
																	}
																}
																$$ = new symbolInfo($1->getName() + "," + $3->getName() + " " + $4->getName(), "non_terminal");
																logfile<<"Line "<<line_count<<": parameter_list : parameter_list COMMA type_specifier ID"<<endl<<endl;
																logfile<<$$->getName()<<endl<<endl;
																cout<<"At line no: "<<line_count<<" parameter_list  : parameter_list COMMA type_specifier ID"<<endl<<endl;
																cout<<$$->getName()<<endl<<endl;
															}

		| parameter_list COMMA type_specifier
												{
													my_parameters.push_back($3->getName());
													$$ = new symbolInfo($1->getName() + "," + $3->getName(), "non_terminal");
													logfile<<"Line "<<line_count<<": parameter_list  : parameter_list COMMA type_specifier"<<endl<<endl;
													logfile<<$$->getName()<<endl<<endl;
													cout<<"At line no: "<<line_count<<" parameter_list  : parameter_list COMMA type_specifier"<<endl<<endl;
													cout<<$$->getName()<<endl<<endl;
												}

 		| type_specifier ID
		 					{
								my_parameters.push_back($1->getName());
								$2->setVar_type($1->getName());
								$2->setAsm_var("_" + to_string(sc_count+1));
								string s = $2->getName() + "_" + to_string(sc_count+1) + " DW ?";
								data_seg.push_back(s);
								parameters.push_back($2);
								$$ = new symbolInfo($1->getName() + " " + $2->getName(), "non_terminal");
								logfile<<"Line "<<line_count<<": parameter_list : type_specifier ID"<<endl<<endl;
								logfile<<$$->getName()<<endl<<endl;
								cout<<"At line no: "<<line_count<<" parameter_list  : type_specifier ID"<<endl<<endl;
								cout<<$$->getName()<<endl<<endl;
							}

		| type_specifier	
							{
								my_parameters.push_back($1->getName());
								$$ = $1;
								logfile<<"Line "<<line_count<<": parameter_list  : type_specifier"<<endl<<endl;
								logfile<<$1->getName()<<endl<<endl;
								cout<<"At line no: "<<line_count<<" parameter_list  : type_specifier"<<endl<<endl;
								cout<<$1->getName()<<endl<<endl;
							}

		| parameter_list COMMA type_specifier ID error
															{
																$4->setVar_type($3->getName());
																parameters.push_back($4);
																my_parameters.push_back($3->getName());
																if (parameters.size() != 0)
																{
																	for (int i=0; i<parameters.size(); i++)
																	{
																		for(int j = i+1; j <parameters.size(); j++)
																		{
																			if (parameters[i]->getName() == parameters[j]->getName())
																			{
																				parameters.pop_back();
																				error_count++;
																				errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<parameters[i]->getName()<<" in parameter"<<endl<<endl;
																				logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<parameters[i]->getName()<<" in parameter"<<endl<<endl;
																			}
																		}
																	}
																}
																$$ = new symbolInfo($1->getName() + "," + $3->getName() + " " + $4->getName(), "non_terminal");
																logfile<<"Line "<<line_count<<": parameter_list : parameter_list COMMA type_specifier ID"<<endl<<endl;
																logfile<<$$->getName()<<endl<<endl;
																logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
																yyerrok;
																yyclearin;
															}

		| parameter_list COMMA type_specifier error
														{
															my_parameters.push_back($3->getName());
															$$ = new symbolInfo($1->getName() + "," + $3->getName(), "non_terminal");
															logfile<<"Line "<<line_count<<": parameter_list  : parameter_list COMMA type_specifier"<<endl<<endl;
															logfile<<$$->getName()<<endl<<endl;
															logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
															yyerrok;
															yyclearin;
														}

		| type_specifier ID error
									{
										my_parameters.push_back($1->getName());
										$2->setVar_type($1->getName());
										parameters.push_back($2);
										$$ = new symbolInfo($1->getName() + " " + $2->getName(), "non_terminal");
										logfile<<"Line "<<line_count<<": parameter_list : type_specifier ID"<<endl<<endl;
										logfile<<$$->getName()<<endl<<endl;
										logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
										//errorfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
										yyerrok;
										yyclearin;
									}

		| type_specifier error
								{
									$$ = $1;
									logfile<<"Line "<<line_count<<": parameter_list  : type_specifier"<<endl<<endl;
									logfile<<$1->getName()<<endl<<endl;
									logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
									errorfile<<"Error at line "<<line_count<<": 1th parameter's name not given in function definition of "<<for_func_name[0]->getName()<<endl<<endl;
									logfile<<"Error at line "<<line_count<<": 1th parameter's name not given in function definition of "<<for_func_name[0]->getName()<<endl<<endl;
									yyerrok;
									yyclearin;
								}		
		
 		;

compound_statement : LCURL dummy_state_two statements RCURL
												{
													//symbolInfo s = new symbolInfo('\n',"abc");
													string c = "\n";
													$$ = new symbolInfo("{" + c + $3->getName() + '\n' + "}\n", "non_terminal");
													logfile<<"Line "<<line_count<<": compound_statement : LCURL statements RCURL"<<endl<<endl;
													//logfile<<c;
													logfile<<$$->getName()<<endl<<endl;
													cout<<"At line no: "<<line_count<<" compound_statement : LCURL statements RCURL"<<endl<<endl;
													cout<<$$->getName()<<endl<<endl;

													$$->setCode($3->getCode());

													logfile<<endl<<endl;
													table->printAST(logfile);
													//logfile<<"ScopeTable with id "<<table->giveid()<<" removed"<<endl<<endl;
													cout<<"ScopeTable with id "<<table->giveid()<<" removed"<<endl<<endl;
													table->exitScope();
												}

 		    | LCURL dummy_state_two RCURL	
			 				{
								string c = "\n";
								$$ = new symbolInfo("{" + c + '\n' + "}", "non_terminal");
								logfile<<"Line "<<line_count<<": compound_statement : LCURL RCURL"<<endl<<endl;
								//logfile<<c;
								logfile<<$$->getName()<<endl<<endl;
								cout<<"At line no: "<<line_count<<" compound_statement : LCURL RCURL"<<endl<<endl;
								cout<<$$->getName()<<endl<<endl;

								logfile<<endl<<endl<<endl;
								table->printAST(logfile);
								//logfile<<"ScopeTable with id "<<table->giveid()<<" removed"<<endl<<endl;
								cout<<"ScopeTable with id "<<table->giveid()<<" removed"<<endl<<endl;
								table->exitScope();
							}

			| LCURL dummy_state_two statements error
										{
											//symbolInfo s = new symbolInfo('\n',"abc");
											error_count++;
											logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
											//errorfile<<"Invalid scoping"<<endl<<endl;
											logfile<<"Invalid scoping"<<endl<<endl;
											string c = "\n";
											$$ = new symbolInfo("{" + c + $3->getName() + '\n' + "}\n", "non_terminal");
											logfile<<"Line "<<line_count<<": compound_statement : LCURL statements RCURL"<<endl<<endl;
											//logfile<<c;
											logfile<<$$->getName()<<endl<<endl;
											cout<<"At line no: "<<line_count<<" compound_statement : LCURL statements RCURL"<<endl<<endl;
											cout<<$$->getName()<<endl<<endl;

											//logfile<<endl<<endl;
											//table->printAST(logfile);
											//logfile<<"ScopeTable with id "<<table->giveid()<<" removed"<<endl<<endl;
											cout<<"ScopeTable with id "<<table->giveid()<<" removed"<<endl<<endl;
											//table->exitScope();
											yyerrok;
											yyclearin;
										}

 		    ;


dummy_state_two :
					{
						if (in_func == 0)
						{
							table->enterScope();
							sc_count++;
							//logfile<<"New ScopeTable with id "<<table->giveid()<<" created"<<endl<<endl;
							cout<<"New ScopeTable with id "<<table->giveid()<<" created"<<endl<<endl;
						}
						in_func = 0;
					}


var_declaration : type_specifier declaration_list SEMICOLON 	
																{
																	logfile<<"Line "<<line_count<<": var_declaration : type_specifier declaration_list SEMICOLON"<<endl<<endl;
																	cout<<"At line no: "<<line_count<<" var_declaration : type_specifier declaration_list SEMICOLON"<<endl<<endl;
																	if ($1->getName() == "void")
																	{
																		error_count++;
																		errorfile<<"Error at line "<<line_count<<": Variable type cannot be void"<<endl<<endl;
																		logfile<<"Error at line "<<line_count<<": Variable type cannot be void"<<endl<<endl;
																	}
																	else
																	{
																		vector<string> v;
																		for (int i = 0; i < vec_var.size(); i++ )
																		{
																			my_si = new symbolInfo(vec_var[i]->getName(),vec_var[i]->getType(),$1->getName());
																			if (vec_var[i]->getVar_type() == "array ")
																				my_si->setVar_type("array " + my_si->getVar_type());
																			table->insert(vec_var[i]->getName(),vec_var[i]->getType(),my_si->getVar_type(),"",v,false,"",vec_var[i]->getAsm_var());
																			my_var.push_back(my_si);
																		}
																	}
																	vec_var.clear();
																	for_func_name.clear();
																	//table->printAST(logfile);
																	//cout<<"type_specifier declaration_list SEMICOLON"<<endl;
																	//cout<<$1->getName()<<endl;
																	$$ = new symbolInfo($1->getName()+ " " + $2->getName() + ";" , "terminal");
																	logfile<<$$->getName()<<endl<<endl;
																	cout<<$$->getName()<<endl<<endl;
																	/*for (int i = 0; i < my_var.size(); i++ )
																	{
																		cout<<my_var[i]->getName()<<" "<<my_var[i]->getType()<<" "<<my_var[i]->getVar_type()<<endl;
																	}*/
																	return_type.clear();
																}

 		 ;
 		 
type_specifier	: INT
						{
							$$ = new symbolInfo("int","terminal");
							cout<<"At line no: "<<line_count<<" type_specifier : INT"<<endl<<endl;
							cout<<"int"<<endl<<endl;
							logfile<<"Line "<<line_count<<": type_specifier : INT"<<endl<<endl;
							logfile<<"int"<<endl<<endl;
							//cout<<$1<<endl;
							return_type.push_back($$);
						}
 		| FLOAT			
		 				{ 	
							$$ = new symbolInfo("float","terminal");
							cout<<"At line no: "<<line_count<<" type_specifier : FLOAT"<<endl<<endl;
							cout<<"float"<<endl<<endl;
							logfile<<"Line "<<line_count<<": type_specifier : FLOAT"<<endl<<endl;
							logfile<<"float"<<endl<<endl;
							return_type.push_back($$);
						}
 		| VOID			
		 				{
							 //cout<<"abcd"<<endl;
							 $$ = new symbolInfo("void","terminal");
							 cout<<"At line no: "<<line_count<<" type_specifier : VOID"<<endl<<endl;
							 cout<<"void"<<endl<<endl;
							 logfile<<"Line "<<line_count<<": type_specifier : VOID"<<endl<<endl;
							 logfile<<"void"<<endl<<endl;
							 return_type.push_back($$);
						}
 		;
 		

 declaration_list : declaration_list COMMA ID	
 												{	 
													 my_si = table->getCs()->lookUp($3->getName());
													 if (my_si != NULL)
													 {
														error_count++;
														errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$3->getName()<<endl<<endl;
														logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$3->getName()<<endl<<endl;
													 }
													 $3->setAsm_var("_" + to_string(sc_count));
													 //errorfile<<$3->getName() + $3->getAsm_var()<<endl;
													 vec_var.push_back($3);
													 //cout<<"list comma ID"<<endl;
													 for_func_name.clear();
													 string s = $3->getName() + "_" + to_string(sc_count) + " DW ?";
													 data_seg.push_back(s);
													 logfile<<"Line "<<line_count<<": declaration_list : declaration_list COMMA ID"<<endl<<endl;
													 cout<<"At line no: "<<line_count<<" declaration_list : declaration_list COMMA ID"<<endl<<endl;
													 $$ = new symbolInfo($1->getName()+ "," + $3->getName(),"non_terminal");
													 logfile<<$$->getName()<<endl<<endl;
													 cout<<$$->getName()<<endl<<endl;
												}

			| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
																	{
																		my_si = table->getCs()->lookUp($3->getName());
													 					if (my_si != NULL)
													 					{
																			error_count++;
																			errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$3->getName()<<endl<<endl;
																			logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$3->getName()<<endl<<endl;
													 					}
																		$3->setVar_type("array ");
																		$3->setAsm_var("_" + to_string(sc_count));
													 					//errorfile<<$3->getName() + $3->getAsm_var()<<endl;
																		vec_var.push_back($3);
																		for_func_name.clear();
																		string s = $3->getName() + "_" + to_string(sc_count) + " DW " + $5->getName() + " DUP(?)";
																		data_seg.push_back(s);
																		//cout<<$1->getName()<<endl<<endl;
																		$$ = new symbolInfo($1->getName() + "," + $3->getName() + "[" + $5->getName() + "]","non_terminal");
																		logfile<<"Line "<<line_count<<": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;
																		logfile<<$$->getName()<<endl<<endl;
																		cout<<"At line no: "<<line_count<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;
																		cout<<$$->getName()<<endl<<endl;
																	}			

			| ID		
					{
						my_si = table->getCs()->lookUp($1->getName());
						if (my_si != NULL)
						{
							error_count++;
							errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->getName()<<endl<<endl;
							logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->getName()<<endl<<endl;
						}
						$1->setAsm_var("_" + to_string(sc_count));
						//errorfile<<$1->getName() + $1->getAsm_var()<<endl;
						vec_var.push_back($1);
						for_func_name.clear();
						string s = $1->getName() + "_" + to_string(sc_count) + " DW ?";
						data_seg.push_back(s);
						//cout<<$1->getName()<<endl<<endl;
						logfile<<"Line "<<line_count<<": declaration_list : ID"<<endl<<endl;
						logfile<<$1->getName()<<endl<<endl;
						cout<<"At line no: "<<line_count<<" declaration_list : ID"<<endl<<endl;
						cout<<$1->getName()<<endl<<endl;
						$$ = $1;
					}
			
			| ID LTHIRD CONST_INT RTHIRD
											{
												my_si = table->getCs()->lookUp($1->getName());
												if (my_si != NULL)
												{
													error_count++;
													errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->getName()<<endl<<endl;
													logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->getName()<<endl<<endl;
												}
												$1->setVar_type("array ");
												$1->setAsm_var("_" + to_string(sc_count));
												//errorfile<<$1->getName() + $1->getAsm_var()<<endl;
												vec_var.push_back($1);
												for_func_name.clear();
												string s = $1->getName() + "_" + to_string(sc_count) + " DW " + $3->getName() + " DUP(?)";
												data_seg.push_back(s);
												//cout<<$1->getName()<<endl<<endl;
												$$ = new symbolInfo($1->getName() + "[" + $3->getName() + "]","non_terminal");
												logfile<<"Line "<<line_count<<": declaration_list : ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;
												logfile<<$$->getName()<<endl<<endl;
												cout<<"At line no: "<<line_count<<" declaration_list : ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;
												cout<<$$->getName()<<endl<<endl;
											}

			| declaration_list error COMMA ID
													{
														my_si = table->getCs()->lookUp($4->getName());
														if (my_si != NULL)
														{
															error_count++;
															errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$4->getName()<<endl<<endl;
															logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$4->getName()<<endl<<endl;
														}
														vec_var.push_back($4);
														//cout<<"list comma ID"<<endl;
														for_func_name.clear();
														logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
														logfile<<$1->getName()<<endl<<endl;
														logfile<<"Line "<<line_count<<": declaration_list : declaration_list COMMA ID"<<endl<<endl;
														cout<<"At line no: "<<line_count<<" declaration_list : declaration_list COMMA ID"<<endl<<endl;
														$$ = new symbolInfo($1->getName()+ "," + $4->getName(),"non_terminal");
														logfile<<$$->getName()<<endl<<endl;
														cout<<$$->getName()<<endl<<endl;
													}	
			
			| declaration_list error COMMA ID LTHIRD CONST_INT RTHIRD
																			{
																				my_si = table->getCs()->lookUp($4->getName());
																				if (my_si != NULL)
																				{
																					error_count++;
																					errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$4->getName()<<endl<<endl;
																					logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$4->getName()<<endl<<endl;
																				}
																				$4->setVar_type("array ");
																				vec_var.push_back($4);
																				for_func_name.clear();
																				logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
																				logfile<<$1->getName()<<endl<<endl;
																				//cout<<$1->getName()<<endl<<endl;
																				$$ = new symbolInfo($1->getName() + "," + $4->getName() + "[" + $6->getName() + "]","non_terminal");
																				logfile<<"Line "<<line_count<<": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;
																				logfile<<$$->getName()<<endl<<endl;
																				cout<<"At line no: "<<line_count<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;
																				cout<<$$->getName()<<endl<<endl;
																			}

			| error ID
							{
								my_si = table->getCs()->lookUp($2->getName());
								if (my_si != NULL)
								{
									error_count++;
									errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl<<endl;
									logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl<<endl;
								}
								vec_var.push_back($2);
								for_func_name.clear();
								logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
								logfile<<$2->getName()<<endl<<endl;
								//cout<<$1->getName()<<endl<<endl;
								logfile<<"Line "<<line_count<<": declaration_list : ID"<<endl<<endl;
								logfile<<$2->getName()<<endl<<endl;
								cout<<"At line no: "<<line_count<<" declaration_list : ID"<<endl<<endl;
								cout<<$2->getName()<<endl<<endl;
								$$ = $2;
							}		

			| error ID LTHIRD CONST_INT RTHIRD
													{
														my_si = table->getCs()->lookUp($2->getName());
														if (my_si != NULL)
														{
															error_count++;
															errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl<<endl;
															logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl<<endl;
														}
														$2->setVar_type("array ");
														vec_var.push_back($2);
														for_func_name.clear();
														logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
														logfile<<$2->getName()<<endl<<endl;
														//cout<<$1->getName()<<endl<<endl;
														$$ = new symbolInfo($2->getName() + "[" + $4->getName() + "]","non_terminal");
														logfile<<"Line "<<line_count<<": declaration_list : ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;
														logfile<<$$->getName()<<endl<<endl;
														cout<<"At line no: "<<line_count<<" declaration_list : ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;
														cout<<$$->getName()<<endl<<endl;
													}
			
			;

statements : statement	
						{
							$$ = $1;
							logfile<<"Line "<<line_count<<": statements : statement"<<endl<<endl;
							logfile<<$$->getName()<<endl<<endl<<endl;
							cout<<"At line no: "<<line_count<<" statements : statement"<<endl<<endl;
							cout<<$$->getName()<<endl<<endl;
						}

	   | func_definition
	   						{
								logfile<<"Line "<<line_count<<": statements : func_definition"<<endl<<endl;
								logfile<<$1->getName()<<endl<<endl<<endl;
								$$ = $1; 
								error_count++;
								logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
								errorfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
								errorfile<<"Invalid scoping"<<endl<<endl; 
								//cout<<"var_declaration"<<endl;
								//cout<<$1->getName()<<endl;
								cout<<"At line no: "<<line_count<<" unit : func_definition"<<endl<<endl;
								cout<<$1->getName()<<endl<<endl;
							}

	   | func_declaration
	   						{
								logfile<<"Line "<<line_count<<": statements : func_declaration"<<endl<<endl;
								logfile<<$1->getName()<<endl<<endl<<endl;
								$$ = $1; 
								error_count++;
								logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
								errorfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
								errorfile<<"Invalid scoping"<<endl<<endl; 
								//cout<<"var_declaration"<<endl;
								//cout<<$1->getName()<<endl;
								cout<<"At line no: "<<line_count<<" unit : func_definition"<<endl<<endl;
								cout<<$1->getName()<<endl<<endl;
							}

	   | statements statement
	   							{
									$$ = new symbolInfo($1->getName() + '\n' + $2->getName(),"non_terminal");
									logfile<<"Line "<<line_count<<": statements : statements statement"<<endl<<endl;
									logfile<<$$->getName()<<endl<<endl<<endl;

									$$->setCode($1->getCode() + my_newline + $2->getCode());

									cout<<"At line no: "<<line_count<<" statements : statements statement"<<endl<<endl;
									cout<<$$->getName()<<endl<<endl;
								}

	   | statements func_definition
	   									{
											logfile<<"Line "<<line_count<<": statements : statements func_definition"<<endl<<endl;
											logfile<<$1->getName()<<endl<<endl<<endl;
											$$ = new symbolInfo($1->getName() + '\n' + $2->getName(),"non_terminal");
											error_count++;
											logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
											errorfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
											errorfile<<"Invalid scoping"<<endl<<endl; 
											//cout<<"var_declaration"<<endl;
											//cout<<$1->getName()<<endl;
											cout<<"At line no: "<<line_count<<" unit : func_definition"<<endl<<endl;
											cout<<$1->getName()<<endl<<endl;
										}		

	   | statements func_declaration
	   									{
											logfile<<"Line "<<line_count<<": statements : statements func_declaration"<<endl<<endl;
											logfile<<$1->getName()<<endl<<endl<<endl;
											$$ = new symbolInfo($1->getName() + '\n' + $2->getName(),"non_terminal");
											error_count++;
											logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
											errorfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
											errorfile<<"Invalid scoping"<<endl<<endl; 
											//cout<<"var_declaration"<<endl;
											//cout<<$1->getName()<<endl;
											cout<<"At line no: "<<line_count<<" unit : func_definition"<<endl<<endl;
											cout<<$1->getName()<<endl<<endl;
										}
		
	   ;

statement : var_declaration
								{
									$$ = $1;
									logfile<<"Line "<<line_count<<": statement : var_declaration"<<endl<<endl;
									logfile<<$$->getName()<<endl<<endl<<endl;
									cout<<"At line no: "<<line_count<<" statement : var_declaration"<<endl<<endl;
									cout<<$$->getName()<<endl<<endl;
								}

	  | expression_statement
	  							{
									$$ = $1;
									logfile<<"Line "<<line_count<<": statement : expression_statement"<<endl<<endl;
									logfile<<$$->getName()<<endl<<endl<<endl;
									cout<<"At line no: "<<line_count<<" statement : expression_statement"<<endl<<endl;
									cout<<$$->getName()<<endl<<endl;
								}

	  | compound_statement
	  							{
									$$ = $1;
									logfile<<"Line "<<line_count<<": statement : compound_statement"<<endl<<endl;
									logfile<<$$->getName()<<endl<<endl<<endl;
									cout<<"At line no: "<<line_count<<" statement : compound_statement"<<endl<<endl;
									cout<<$$->getName()<<endl<<endl;
								}

	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  																						{
																								$$ = new symbolInfo("for(" + $3->getName() + $4->getName() + $5->getName() + ")" + $7->getName(),"non_terminal");
																								logfile<<"Line "<<line_count<<": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<endl<<endl;
																								logfile<<$$->getName()<<endl<<endl<<endl;

																								string my_lab_1 = newLabel();
																								string my_lab_2 = newLabel();
																								//errorfile<<$4->getCode()<<"  "<<$4->getAsm_var()<<endl;
																								string st_comment = my_tab + ";Line " + to_string(line_count) + ": for block" + my_newline + my_newline;
																								string my_code = st_comment + $3->getCode() + my_lab_1 + ":" + my_newline + $4->getCode() + my_tab + "MOV AX, " + $4->getAsm_var() + my_newline + my_tab + "CMP AX, 0" + my_newline + my_tab + "JE " + my_lab_2 + my_newline;
																								my_code = my_code + $7->getCode() + $5->getCode() + my_tab + "JMP " + my_lab_1 + my_newline + my_lab_2 + ":" + my_newline; 
																								$$->setCode(my_code);

																								cout<<"At line no: "<<line_count<<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<endl<<endl;
																								cout<<$$->getName()<<endl<<endl;
																							}

	  | IF LPAREN expression RPAREN statement	%prec LOWER_THAN_ELSE
	  											{
													$$ = new symbolInfo("if (" + $3->getName() + ")" + $5->getName() , "non_terminal");
													logfile<<"Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement"<<endl<<endl;
													logfile<<$$->getName()<<endl<<endl<<endl;

													string my_label = newLabel();
													string my_code = $3->getCode() + my_tab + "MOV AX, " + $3->getAsm_var() + my_newline + my_tab + "CMP AX, 0" + my_newline + my_tab + "JE " + my_label + my_newline;
													my_code = my_code + $5->getCode() + my_newline + my_label + ":" + my_newline;
													$$->setCode(my_code);
													cout<<"At line no: "<<line_count<<" statement : IF LPAREN expression RPAREN statement"<<endl<<endl;
													cout<<$$->getName()<<endl<<endl;
												}

	  
	  | IF LPAREN expression RPAREN statement ELSE statement
	  															{
																	$$ = new symbolInfo("if (" + $3->getName() + ")" + $5->getName() + '\n' + "else\n" + $7->getName(), "non_terminal");
																	logfile<<"Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl<<endl;
																	logfile<<$$->getName()<<endl<<endl<<endl;
																	
																	string my_lab_1 = newLabel();
																	string my_lab_2 = newLabel();
																	string st_comment = my_tab + ";Line " + to_string(line_count) + ": if_else block" + my_newline + my_newline;
																	string my_code = st_comment + $3->getCode() + my_tab + "MOV AX, " + $3->getAsm_var() + my_newline + my_tab + "CMP AX, 0" + my_newline;
																	my_code = my_code + my_tab + "JE " + my_lab_1 + my_newline + $5->getCode() + my_tab + "JMP " + my_lab_2 + my_newline;
																	my_code = my_code + my_lab_1 + ":" + my_newline + $7->getCode() + my_newline + my_lab_2 + ":" + my_newline;
																	$$->setCode(my_code);

																	cout<<"At line no: "<<line_count<<" statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl<<endl;
																	cout<<$$->getName()<<endl<<endl;
																}

	  | WHILE LPAREN expression RPAREN statement
	  												{
														$$ = new symbolInfo("while (" + $3->getName() + ")" + $5->getName() , "non_terminal");
														logfile<<"Line "<<line_count<<": statement : WHILE LPAREN expression RPAREN statement"<<endl<<endl;
														logfile<<$$->getName()<<endl<<endl<<endl;

														string my_lab_1 = newLabel();
														string my_lab_2 = newLabel();
														string st_comment = my_tab + ";Line " + to_string(line_count) + ": while block" + my_newline + my_newline;
														string my_code = st_comment + my_lab_1 + ":" + my_newline + $3->getCode() + my_tab + "MOV AX, " + $3->getAsm_var() + my_newline + my_tab + "CMP AX, 0" + my_newline + my_tab + "JE " + my_lab_2 + my_newline;
														my_code = my_code + $5->getCode() + my_tab + "JMP " + my_lab_1 + my_newline + my_lab_2 + ":" + my_newline;
														$$->setCode(my_code);

														cout<<"At line no: "<<line_count<<" statement : WHILE LPAREN expression RPAREN statement"<<endl<<endl;
														cout<<$$->getName()<<endl<<endl;
													}

	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  											{
													
													$$ = new symbolInfo("printf(" + $3->getName() + ");" , "non_terminal");
													logfile<<"Line "<<line_count<<": statement : PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl<<endl;
													my_si = table->lookup($3->getName());
													if (my_si == NULL)
													{
														error_count++;
														errorfile<<"Error at line "<<line_count<<": Undeclared variable "<<$3->getName()<<endl<<endl;
														logfile<<"Error at line "<<line_count<<": Undeclared variable "<<$3->getName()<<endl<<endl;
													}
													logfile<<$$->getName()<<endl<<endl<<endl;

													string st_comment = my_tab + ";Line " + to_string(line_count) + ": println(" + $3->getName() + ")" + my_newline + my_newline;
													if(my_si != NULL)
													{
														string var_n = my_si->getName() + my_si->getAsm_var();
														string my_code = st_comment + my_tab + "MOV BX, " + var_n + my_newline + my_tab + "PUSH BX" + my_newline + my_tab + "CALL OUT_NUM" + my_newline;
														$$->setCode(my_code);
													}

													cout<<"At line no: "<<line_count<<" statement : PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl<<endl;
													cout<<$$->getName()<<endl<<endl;
												}

	  | RETURN expression SEMICOLON
	  									{
											$$ = new symbolInfo("return " + $2->getName() + ";","non_terminal");
											logfile<<"Line "<<line_count<<": statement : RETURN expression SEMICOLON"<<endl<<endl;
											logfile<<$$->getName()<<endl<<endl<<endl;

											
											string pop_reg = my_tab + "POP BP" + my_newline + my_tab + "POP DI" + my_newline + my_tab + "POP DX" + my_newline + my_tab + "POP CX" + my_newline + my_tab + "POP BX" + my_newline + my_tab + "POP AX" + my_newline; 
											string st_comment = my_tab + ";Line " + to_string(line_count) + ": return " + $2->getName() + my_newline + my_newline;
											if(curr_func_name != "main")
											{
												string my_code = $2->getCode() + st_comment + pop_reg + my_tab + "PUSH " + $2->getAsm_var() + my_newline;
												my_code = my_code + my_tab + "PUSH ADDRESS_" + to_string(sc_count) + my_newline + my_tab + "RET" + my_newline;
												$$->setCode(my_code);
											}

											//errorfile<<curr_func_name<<endl;
											cout<<"At line no: "<<line_count<<" statement : RETURN expression SEMICOLON"<<endl<<endl;
											cout<<$$->getName()<<endl<<endl;
										}
	  ;

expression_statement 	: SEMICOLON		
										{
											$$ = new symbolInfo(";", "non_terminal");
											logfile<<"Line "<<line_count<<": expression_statement : SEMICOLON"<<endl<<endl;
											logfile<<$$->getName()<<endl<<endl;
											cout<<"At line no: "<<line_count<<" expression_statement : SEMICOLON"<<endl<<endl;
											cout<<$$->getName()<<endl<<endl;
										}	

			| expression SEMICOLON 
									{
										$$ = new symbolInfo($1->getName() + ";","non_terminal");
										logfile<<"Line "<<line_count<<": expression_statement : expression SEMICOLON"<<endl<<endl;
										logfile<<$$->getName()<<endl<<endl;

										$$->setCode($1->getCode());
										$$->setAsm_var($1->getAsm_var());
										cout<<"At line no: "<<line_count<<" expression_statement : expression SEMICOLON"<<endl<<endl;
										cout<<$$->getName()<<endl<<endl;
									}

			| expression error
									{
										$$ = new symbolInfo($1->getName() + ";","non_terminal");
										error_count++;
										logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
										//errorfile<<"abc"<<endl<<endl;
									}						
			;

variable : ID 		
					{
						ty_mismatch = false;
						$$ = $1;
						logfile<<"Line "<<line_count<<": variable : ID"<<endl<<endl;
						my_si = table->getCs()->lookUp($1->getName());
						if (my_si != NULL)
						{
							//$$ = my_si;
							$$->setName(my_si->getName());
							$$->setType(my_si->getType());
							$$->setVar_type(my_si->getVar_type());
							$$->setFunc_return_type(my_si->getFunc_return_type());
							$$->setFunc_parameters(my_si->getFunc_parameters());
							$$->setDefined(my_si->getDefined());
							$$->setNext(my_si->getNext());
							if (my_si->getVar_type() == "array int" || my_si->getVar_type() == "array float")
							{
								ty_mismatch = true;
								error_count++;
								errorfile<<"Error at line "<<line_count<<": Type mismatch, "<<$1->getName()<<" is an array"<<endl<<endl;
								logfile<<"Error at line "<<line_count<<": Type mismatch, "<<$1->getName()<<" is an array"<<endl<<endl;
								//errorfile<<my_si->getVar_type()<<"   "<<$3->getType()<<endl;
							}
						}
						else if ( table->lookup($1->getName()) == NULL)
						{
							error_count++;
							errorfile<<"Error at line "<<line_count<<": Undeclared variable "<<$1->getName()<<endl<<endl;
							logfile<<"Error at line "<<line_count<<": Undeclared variable "<<$1->getName()<<endl<<endl;
							$$->setVar_type("int");
						}
						else if ( table->lookup($1->getName()) != NULL)
						{
							my_si = table->lookup($1->getName());
							//$$ = my_si;
							$$->setName(my_si->getName());
							$$->setType(my_si->getType());
							$$->setVar_type(my_si->getVar_type());
							$$->setFunc_return_type(my_si->getFunc_return_type());
							$$->setFunc_parameters(my_si->getFunc_parameters());
							$$->setDefined(my_si->getDefined());
							$$->setNext(my_si->getNext());
						}
						logfile<<$$->getName()<<endl<<endl;

						if(my_si != NULL)
						{
							//errorfile<<"in var "<<my_si->getName()<<"   "<<my_si->getAsm_var()<<endl;
							string var_n = my_si->getName() + my_si->getAsm_var();
							$$->setAsm_var(var_n);
							$$->setCode("");
						}

						cout<<"At line no: "<<line_count<<" variable : ID"<<endl<<endl;
						cout<<$$->getName()<<endl<<endl;
						for_func_name.clear();
					}

	 | ID LTHIRD expression RTHIRD 
	 								{
										ty_mismatch = false;
										$$ = new symbolInfo($1->getName() + "[" + $3->getName() + "]", "non_terminal");
										logfile<<"Line "<<line_count<<": variable : ID LTHIRD expression RTHIRD"<<endl<<endl;
										if ( $3->getType() == "CONST_FLOAT" || $3->getVar_type() == "float")
										{
											error_count++;
											errorfile<<"Error at line "<<line_count<<": Expression inside third brackets not an integer"<<endl<<endl;
											logfile<<"Error at line "<<line_count<<": Expression inside third brackets not an integer"<<endl<<endl;
										}
										my_si = table->getCs()->lookUp($1->getName());
										if (my_si != NULL)
										{
											if(my_si->getVar_type() == "array int")
												$$->setVar_type("int");
											else if(my_si->getVar_type() == "array float")
												$$->setVar_type("float");

											if (my_si->getVar_type() == "int" || my_si->getVar_type() == "float")
											{
												ty_mismatch = true;
												error_count++;
												errorfile<<"Error at line "<<line_count<<": "<<$1->getName()<<" not an array"<<endl<<endl;
												logfile<<"Error at line "<<line_count<<": "<<$1->getName()<<" not an array"<<endl<<endl;
												//errorfile<<my_si->getVar_type()<<"   "<<$3->getType()<<endl;
											}
										}
										else if ( table->lookup($1->getName()) == NULL)
										{
											error_count++;
											errorfile<<"Error at line "<<line_count<<": Undeclared variable "<<$1->getName()<<endl<<endl;
											logfile<<"Error at line "<<line_count<<": Undeclared variable "<<$1->getName()<<endl<<endl;
											$$->setVar_type("int");
										}
										else if ( table->lookup($1->getName()) != NULL)
										{
											my_si = table->lookup($1->getName());
											$$->setVar_type(my_si->getVar_type());
										}
										logfile<<$$->getName()<<endl<<endl;

										if(my_si != NULL)
										{
											string var_n = my_si->getName() + my_si->getAsm_var() + "[di]";
											$$->setAsm_var(var_n);
											string my_code = $3->getCode() + my_tab + "MOV DI, " + $3->getAsm_var() + my_newline + my_tab + "ADD DI, DI" + my_newline;
											$$->setCode(my_code);
										}

										cout<<"At line no: "<<line_count<<" variable : ID LTHIRD expression RTHIRD"<<endl<<endl;
										cout<<$$->getName()<<endl<<endl;
										for_func_name.clear();
									}
	 ;

expression : logic_expression	
								{
									$$ = $1;
									logfile<<"Line "<<line_count<<": expression : logic expression"<<endl<<endl;
									logfile<<$$->getName()<<endl<<endl;
									cout<<"At line no: "<<line_count<<" expression : logic expression"<<endl<<endl;
									cout<<$$->getName()<<endl<<endl;
								}

	   | variable ASSIGNOP logic_expression 	
	   											{
													//errorfile<<$3->getName()<<" "<<$3->getType()<<" "<<$3->getVar_type()<<endl<<endl;
													logfile<<"Line "<<line_count<<": expression : variable ASSIGNOP logic_expression"<<endl<<endl;
													string l_var_name="";
													string l_var_type="";
													for(int i=0;i<$3->getName().length();i++)
													{
														if($3->getName()[i] != '[')
															l_var_name = l_var_name + $3->getName()[i];
														else
															break; 
													}
													my_si_2 = table->lookup(l_var_name);
													if(my_si_2 != NULL)
														l_var_type = my_si_2->getVar_type();

													string s;
													string var_name = "";
													string var_type = "";
													for(int i=0;i<$1->getName().length();i++)
													{
														if($1->getName()[i] != '[')
															var_name = var_name + $1->getName()[i];
														else
															break; 
													}
													if ( $3->getType() == "CONST_INT" || $3->getVar_type() == "int" || $3->getVar_type() == "array int")
														s = "int";
													else if ( $3->getType() == "CONST_FLOAT" || $3->getVar_type() == "float" || $3->getVar_type() == "array float")
														s = "float";
													else if ($3->getVar_type() == "function")
													{
														if ($3->getFunc_return_type() == "void" )
														{
															error_count++;
															errorfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
															logfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
															s = "int";
														}
														else
															s = $3->getFunc_return_type();
													}
													//else
													//	s = "int";
													my_si = table->lookup(var_name);
													//errorfile<<line_count<<" "<<my_si->getVar_type()<<"   "<<$3->getVar_type()<<endl;
													$$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(), "non_terminal");
													
													if (my_si != NULL)
													{
														if (my_si->getVar_type() == "array int")
															var_type = "int";
														else if (my_si->getVar_type() == "array float")
															var_type = "float";
														else
															var_type = my_si->getVar_type();
														//errorfile<<line_count<<" "<<my_si->getVar_type()<<"   "<<$3->getVar_type()<<endl;
														if (var_type != s )
														{
															if ((my_si->getVar_type() == "float" || my_si->getVar_type() == "array float") && s == "int")
																$$->setVar_type("float");
															else
															{
																//errorfile<<var_type<<"    stype"<<s<<"stype2"<<endl<<endl;
																error_count++;
																errorfile<<"Error at line "<<line_count<<": Type Mismatch"<<endl<<endl;
																logfile<<"Error at line "<<line_count<<": Type Mismatch"<<endl<<endl;
																$$->setVar_type("float");
																//errorfile<<my_si->getVar_type()<<"   "<<$3->getType()<<endl;
															}
														}
														else
															$$->setVar_type(var_type);
													}
													logfile<<$$->getName()<<endl<<endl;

													
													string st_comment = my_tab + ";Line " + to_string(line_count) + ": " + $1->getName() + $2->getName() + $3->getName() +my_newline + my_newline;
													string my_code = "";
													//errorfile<<l_var_type<<endl;
													if(my_si != NULL)
													{
														if((my_si->getVar_type() == "array int" || my_si->getVar_type() == "array float") && (l_var_type == "array int" || l_var_type == "array float"))
														{
															//errorfile<<l_var_type<<endl;
															string t = newTemp();
															string t_data = t + " DW ?";
															data_seg.push_back(t_data);
															my_code = $3->getCode() + st_comment + my_tab + "MOV AX, " + $3->getAsm_var() + my_newline + my_tab + "MOV " + t + ", AX" + my_newline + $1->getCode() + my_tab + "MOV AX, " + t + my_newline + my_tab + "MOV " + $1->getAsm_var() + ", AX" + my_newline;
															//my_code = my_code + my_tab + "MOV " + t + ", AX" + my_newline;
															$$->setAsm_var(t);
														}
														else if(my_si->getVar_type() == "array int" || my_si->getVar_type() == "array float")
														{
															string t = newTemp();
															string t_data = t + " DW ?";
															data_seg.push_back(t_data);
															my_code = $3->getCode() + $1->getCode() + st_comment + my_tab + "MOV AX, " + $3->getAsm_var() + my_newline + my_tab + "MOV " + $1->getAsm_var() + ", AX" + my_newline;
															my_code = my_code + my_tab + "MOV " + t + ", AX" + my_newline;
															$$->setAsm_var(t);
														}
														else
														{
															my_code = $1->getCode() + $3->getCode() + st_comment + my_tab + "MOV AX, " + $3->getAsm_var() + my_newline + my_tab + "MOV " + $1->getAsm_var() + ", AX" + my_newline;
															$$->setAsm_var($1->getAsm_var());
														}
													}
													
													$$->setCode(my_code);
													

													cout<<"At line no: "<<line_count<<" expression : variable ASSIGNOP logic_expression"<<endl<<endl;
													cout<<$$->getName()<<endl<<endl;
												}
	   ;

logic_expression : rel_expression 	
									{
										$$ = $1;
										logfile<<"Line "<<line_count<<": logic_expression : rel_expression"<<endl<<endl;
										logfile<<$$->getName()<<endl<<endl;
										cout<<"At line no: "<<line_count<<" logic_expression : rel_expression"<<endl<<endl;
										cout<<$$->getName()<<endl<<endl;
									}

		 | rel_expression LOGICOP rel_expression 	
		 											{
														$$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(), "non_terminal","int");
														logfile<<"Line "<<line_count<<": logic_expression : rel_expression LOGICOP rel_expression"<<endl<<endl;
														/*string s1 = "";
														string s2 = "";
														if ($1->getVar_type() == "function")
															s1 = $1->getFunc_return_type();
														else if ($1->getVar_type() == "array int")
															s1 = "int";
														else if ($1->getVar_type() == "array float")
															s1 = "float";
														else
															s1 = $1->getVar_type();
														
														if ($3->getVar_type() == "function")
															s2 = $3->getFunc_return_type();
														else if ($3->getVar_type() == "array int")
															s2 = "int";
														else if ($3->getVar_type() == "array float")
															s2 = "float";
														else
															s2 = $3->getVar_type();*/
															
														if ($1->getVar_type() == "function" || $3->getVar_type() == "function")
														{
															if ($1->getFunc_return_type() == "void" || $3->getFunc_return_type() == "void" )
															{
																error_count++;
																errorfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
																logfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
															}
														}
														/*else if (s1 != "int" || s2 != "int" )
														{
															error_count++;
															errorfile<<"Error at line "<<line_count<<": Non-Integer operand on LOGICOP operator"<<endl<<endl;
															logfile<<"Error at line "<<line_count<<": Non-Integer operand on LOGICOP operator"<<endl<<endl;
														}*/
														logfile<<$$->getName()<<endl<<endl;

														string my_lab_1 = newLabel();
														string my_lab_2 = newLabel();
														string t = newTemp();
														string t_data = t + " DW ?";
														data_seg.push_back(t_data);

														string st_comment = my_tab + ";Line " + to_string(line_count) + ": " + $1->getName() + $2->getName() + $3->getName() +my_newline + my_newline;
														string my_code = $1->getCode() + $3->getCode() + st_comment;
														//errorfile<<$1->getAsm_var()<<"   "<<$3->getAsm_var()<<endl;
														if($2->getName() == "&&")
														{
															my_code = my_code + my_tab + "CMP " + $1->getAsm_var() + ", 0" + my_newline + my_tab + "JE " + my_lab_1 + my_newline;
															my_code = my_code + my_tab + "CMP " + $3->getAsm_var() + ", 0" + my_newline + my_tab + "JE " + my_lab_1 + my_newline;
															my_code = my_code + my_tab + "MOV " + t + ", 1" + my_newline + my_tab + "JMP " + my_lab_2 + my_newline;
															my_code = my_code + my_lab_1 + ":" + my_newline + my_tab + "MOV " + t + ", 0" + my_newline;
															my_code = my_code + my_lab_2 + ":" + my_newline; 
														}
														if($2->getName() == "||")
														{
															my_code = my_code + my_tab + "CMP " + $1->getAsm_var() + ", 0" + my_newline + my_tab + "JNE " + my_lab_1 + my_newline;
															my_code = my_code + my_tab + "CMP " + $3->getAsm_var() + ", 0" + my_newline + my_tab + "JNE " + my_lab_1 + my_newline;
															my_code = my_code + my_tab + "MOV " + t + ", 0" + my_newline + my_tab + "JMP " + my_lab_2 + my_newline;
															my_code = my_code + my_lab_1 + ":" + my_newline + my_tab + "MOV " + t + ", 1" + my_newline;
															my_code = my_code + my_lab_2 + ":" + my_newline; 
														}
														$$->setCode(my_code);
														$$->setAsm_var(t);

														cout<<"At line no: "<<line_count<<" logic_expression : rel_expression LOGICOP rel_expression"<<endl<<endl;
														cout<<$$->getName()<<endl<<endl;
													}
		 ;

rel_expression	: simple_expression 
										{
											$$ = $1;
											logfile<<"Line "<<line_count<<": rel_expression : simple_expression"<<endl<<endl;
											logfile<<$$->getName()<<endl<<endl;
											cout<<"At line no: "<<line_count<<" rel_expression : simple_expression"<<endl<<endl;
											cout<<$$->getName()<<endl<<endl;
										}

		| simple_expression RELOP simple_expression	
														{
															$$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(), "non_terminal","int");
															logfile<<"Line "<<line_count<<": rel_expression : simple_expression RELOP simple_expression"<<endl<<endl;
															if ($1->getVar_type() == "function" || $3->getVar_type() == "function")
															{
																if ($1->getFunc_return_type() == "void" || $3->getFunc_return_type() == "void" )
																{
																	error_count++;
																	errorfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
																	logfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
																}
															}
															logfile<<$$->getName()<<endl<<endl;

															
															//$$->setCode()
															/*if($2->getName() == "+")
															{
																$$->setCode($1->getCode() )
															}*/

															string my_lab_1 = newLabel();
															string my_lab_2 = newLabel();
															string t = newTemp();
															string t_data = t + " DW ?";
															data_seg.push_back(t_data);
															string st_comment = my_tab + ";Line " + to_string(line_count) + ": " + $1->getName() + $2->getName() + $3->getName() +my_newline + my_newline;
															string my_code = $1->getCode() + $3->getCode() + st_comment + my_tab + "MOV AX, " + $1->getAsm_var() + my_newline + my_tab + "CMP AX, " + $3->getAsm_var() + my_newline;

															if($2->getName() == "<")
															{
																my_code = my_code + my_tab + "JL " + my_lab_1 + my_newline + my_tab + "MOV " + t + ", 0" + my_newline + my_tab + "JMP " + my_lab_2 + my_newline;
																my_code = my_code + my_lab_1 + ":" + my_newline + my_tab + "MOV " + t + ", 1" + my_newline + my_lab_2 + ":" + my_newline; 
															}
															else if($2->getName() == "<=")
															{
																my_code = my_code + my_tab + "JLE " + my_lab_1 + my_newline + my_tab + "MOV " + t + ", 0" + my_newline + my_tab + "JMP " + my_lab_2 + my_newline;
																my_code = my_code + my_lab_1 + ":" + my_newline + my_tab + "MOV " + t + ", 1" + my_newline + my_lab_2 + ":" + my_newline; 
															}
															else if($2->getName() == ">")
															{
																my_code = my_code + my_tab + "JG " + my_lab_1 + my_newline + my_tab + "MOV " + t + ", 0" + my_newline + my_tab + "JMP " + my_lab_2 + my_newline;
																my_code = my_code + my_lab_1 + ":" + my_newline + my_tab + "MOV " + t + ", 1" + my_newline + my_lab_2 + ":" + my_newline; 
															}
															else if($2->getName() == ">=")
															{
																my_code = my_code + my_tab + "JGE " + my_lab_1 + my_newline + my_tab + "MOV " + t + ", 0" + my_newline + my_tab + "JMP " + my_lab_2 + my_newline;
																my_code = my_code + my_lab_1 + ":" + my_newline + my_tab + "MOV " + t + ", 1" + my_newline + my_lab_2 + ":" + my_newline; 
															}
															else if($2->getName() == "==")
															{
																my_code = my_code + my_tab + "JE " + my_lab_1 + my_newline + my_tab + "MOV " + t + ", 0" + my_newline + my_tab + "JMP " + my_lab_2 + my_newline;
																my_code = my_code + my_lab_1 + ":" + my_newline + my_tab + "MOV " + t + ", 1" + my_newline + my_lab_2 + ":" + my_newline; 
															}
															else if($2->getName() == "!=")
															{
																my_code = my_code + my_tab + "JNE " + my_lab_1 + my_newline + my_tab + "MOV " + t + ", 0" + my_newline + my_tab + "JMP " + my_lab_2 + my_newline;
																my_code = my_code + my_lab_1 + ":" + my_newline + my_tab + "MOV " + t + ", 1" + my_newline + my_lab_2 + ":" + my_newline; 
															}
															$$->setCode(my_code);
															$$->setAsm_var(t);
															//errorfile<<"in r exp"<<"  "<<$$->getAsm_var()<<endl;
															cout<<"At line no: "<<line_count<<" rel_expression : simple_expression RELOP simple_expression"<<endl<<endl;
															cout<<$$->getName()<<endl<<endl;
														}
		;

simple_expression : term 
							{
								$$ = $1;
								logfile<<"Line "<<line_count<<": simple_expression : term"<<endl<<endl;
								logfile<<$$->getName()<<endl<<endl;
								cout<<"At line no: "<<line_count<<" simple_expression : term"<<endl<<endl;
								cout<<$$->getName()<<endl<<endl;
							}

		  | simple_expression ADDOP term 
		  									{
												bool void_chck = false;
												string s1 = "";
												string s2 = "";
												if ($1->getVar_type() == "function")
													s1 = $1->getFunc_return_type();
												else if ($1->getVar_type() == "array int")
													s1 = "int";
												else if ($1->getVar_type() == "array float")
													s1 = "float";
												else
													s1 = $1->getVar_type();
												
												if ($3->getVar_type() == "function")
													s2 = $3->getFunc_return_type();
												else if ($3->getVar_type() == "array int")
													s2 = "int";
												else if ($3->getVar_type() == "array float")
													s2 = "float";
												else
													s2 = $3->getVar_type();

												//errorfile<<line_count<<" "<<$1->getVar_type()<<" "<<$3->getVar_type()<<endl;
												$$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(), "non_terminal");
												logfile<<"Line "<<line_count<<": simple_expression : simple_expression ADDOP term"<<endl<<endl;
												if ($1->getVar_type() == "function" || $3->getVar_type() == "function")
												{
													if ($1->getFunc_return_type() == "void" || $3->getFunc_return_type() == "void" )
													{
														void_chck = true;
														error_count++;
														errorfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
														logfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
														$$->setVar_type("int");
													}
												}
												/*if ( $1->getVar_type() == $3->getVar_type() && $1->getVar_type() != "function")
													$$->setVar_type($1->getVar_type());
												else if ($1->getType() == "CONST_FLOAT" || $3->getType() == "CONST_FLOAT" || $1->getVar_type() == "float" || $3->getVar_type() == "float")
													$$->setVar_type("float");*/
												if (void_chck == false)
												{
													if ( s1 == s2)
														$$->setVar_type(s1);
													else if (s1 == "float" || s2 == "float")
														$$->setVar_type("float");
												}
												void_chck = false;
												logfile<<$$->getName()<<endl<<endl;

												string l_var_name="";
												string l_var_type="";
												for(int i=0;i<$3->getName().length();i++)
												{
													if($3->getName()[i] != '[')
														l_var_name = l_var_name + $3->getName()[i];
													else
														break; 
												}
												my_si_2 = table->lookup(l_var_name);
												if(my_si_2 != NULL)
													l_var_type = my_si_2->getVar_type();

												string s;
												string var_name = "";
												string var_type = "";
												for(int i=0;i<$1->getName().length();i++)
												{
													if($1->getName()[i] != '[')
														var_name = var_name + $1->getName()[i];
													else
														break; 
												}
												my_si = table->lookup(var_name);
												if(my_si != NULL)
													var_type = my_si->getVar_type();
												string st_comment = my_tab + ";Line " + to_string(line_count) + ": " + $1->getName() + $2->getName() + $3->getName() +my_newline + my_newline;
												string t = newTemp();
												string t_data = t + " DW ?";
												data_seg.push_back(t_data);
												string my_code = "";
												if ((var_type == "array int") && (l_var_type == "array int"))
												{
													if($2->getName() == "+")
														my_code = $1->getCode() + my_tab + "MOV AX, " + $1->getAsm_var() + my_newline + $3->getCode() + st_comment + my_tab + my_newline + my_tab + "ADD AX, " + $3->getAsm_var() + my_newline + my_tab + "MOV " + t + ", AX" + my_newline;
													else if($2->getName() == "-")
														my_code = $1->getCode() + my_tab + "MOV AX, " + $1->getAsm_var() + my_newline + $3->getCode() + st_comment + my_tab + my_newline + my_tab + "SUB AX, " + $3->getAsm_var() + my_newline + my_tab + "MOV " + t + ", AX" + my_newline;
												}
												else
												{
													if($2->getName() == "+")
														my_code = $1->getCode() + $3->getCode() + st_comment + my_tab + "MOV AX, " + $1->getAsm_var() + my_newline + my_tab + "ADD AX, " + $3->getAsm_var() + my_newline + my_tab + "MOV " + t + ", AX" + my_newline;
													else if($2->getName() == "-")
														my_code = $1->getCode() + $3->getCode() + st_comment + my_tab + "MOV AX, " + $1->getAsm_var() + my_newline + my_tab + "SUB AX, " + $3->getAsm_var() + my_newline + my_tab + "MOV " + t + ", AX" + my_newline;
												}
												$$->setCode(my_code);
												$$->setAsm_var(t); 

												cout<<"At line no: "<<line_count<<" simple_expression : simple_expression ADDOP term"<<endl<<endl;
												cout<<$$->getName()<<endl<<endl;
											}

		   | simple_expression ADDOP error  term
													{
														$$ = new symbolInfo($1->getName() + $2->getName() + $4->getName(), "non_terminal");
														logfile<<"Line "<<line_count<<": simple_expression : simple_expression ADDOP term"<<endl<<endl;
														logfile<<"Error at line "<<line_count<<": syntax error"<<endl<<endl;
														if ($4->getVar_type() == "function")
														{
															if ($4->getFunc_return_type() == "void" )
															{
																error_count++;
																errorfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
																logfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
																$$->setVar_type("int");
															}
														}
														if ( $1->getVar_type() == $4->getVar_type() && $1->getVar_type() != "function")
															$$->setVar_type($1->getVar_type());
														else if ($1->getType() == "CONST_FLOAT" || $4->getType() == "CONST_FLOAT" || $1->getVar_type() == "float" || $4->getVar_type() == "float")
															$$->setVar_type("float");
														logfile<<$$->getName()<<endl<<endl;
														cout<<"At line no: "<<line_count<<" simple_expression : simple_expression ADDOP term"<<endl<<endl;
														cout<<$$->getName()<<endl<<endl;
													}
		  ;


term :	unary_expression
							{
								$$ = $1;
								logfile<<"Line "<<line_count<<": term : unary_expression"<<endl<<endl;
								logfile<<$$->getName()<<endl<<endl;
								cout<<"At line no: "<<line_count<<" term : unary_expression"<<endl<<endl;
								cout<<$$->getName()<<endl<<endl;
							}
							
     |  term MULOP unary_expression
	 									{
											bool void_chck = false;
											/*string s;
											if ( $3->getType() == "CONST_INT")
												s = "int";
											else if ( $3->getType() == "CONST_FLOAT")
												s = "float";
											else
												s = "int";*/
											//errorfile<<line_count<<" "<<$1->getVar_type()<<" "<<$3->getVar_type()<<endl<<"i"<<endl<<$1->getName()<<endl;
											$$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(),"non_terminal");
											logfile<<"Line "<<line_count<<": term : term MULOP unary_expression"<<endl<<endl;
											if ( $2->getName() == "%")
											{
												string s1 = "";
												string s2 = "";
												if ($1->getVar_type() == "function")
													s1 = $1->getFunc_return_type();
												else
													s1 = $1->getVar_type();
												
												if ($3->getVar_type() == "function")
													s2 = $3->getFunc_return_type();
												else
													s2 = $3->getVar_type(); 
												$$->setVar_type("int");
												if ( s1 != "int" || s2 != "int" )
												{
													error_count++;
													errorfile<<"Error at line "<<line_count<<": Non-Integer operand on modulus operator"<<endl<<endl;
													logfile<<"Error at line "<<line_count<<": Non-Integer operand on modulus operator"<<endl<<endl;
												}
												else if ($3->getName() == "0")
												{
													error_count++;
													errorfile<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
													logfile<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
												}
											}
											else
											{
												string s1 = "";
												string s2 = "";
												if ($1->getVar_type() == "function")
													s1 = $1->getFunc_return_type();
												else if ($1->getVar_type() == "array int")
													s1 = "int";
												else if ($1->getVar_type() == "array float")
													s1 = "float";
												else
													s1 = $1->getVar_type();
												
												if ($3->getVar_type() == "function")
													s2 = $3->getFunc_return_type();
												else if ($3->getVar_type() == "array int")
													s2 = "int";
												else if ($3->getVar_type() == "array float")
													s2 = "float";
												else
													s2 = $3->getVar_type();

												if ($1->getVar_type() == "function" || $3->getVar_type() == "function")
												{
													if ($1->getFunc_return_type() == "void" || $3->getFunc_return_type() == "void" )
													{
														void_chck = true;
														error_count++;
														errorfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
														logfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
														$$->setVar_type("int");
													}
												}
												/*if ( $1->getVar_type() == $3->getVar_type())
													$$->setVar_type($1->getVar_type());
												else if ($1->getVar_type() == "float" || $3->getVar_type() == "float")
													$$->setVar_type("float");
												else
													$$->setVar_type("int");*/
												
												if (void_chck == false)
												{
													if ( s1 == s2)
														$$->setVar_type(s1);
													else if (s1 == "float" || s2 == "float")
														$$->setVar_type("float");
												}
												void_chck = false;
											}
											logfile<<$$->getName()<<endl<<endl;

											string t = newTemp();
											string t_data = t + " DW ?";
											data_seg.push_back(t_data);
											string st_comment = my_tab + ";Line " + to_string(line_count) + ": " + $1->getName() + $2->getName() + $3->getName() +my_newline + my_newline;
											string my_code = "";
											if($2->getName() == "*")
											{
												my_code = $1->getCode() + $3->getCode() + st_comment + my_tab + "MOV AX, " + $1->getAsm_var() + my_newline + my_tab + "MOV BX, " + $3->getAsm_var() + my_newline + my_tab + "MUL BX" + my_newline + my_tab + "MOV " + t + ", AX" + my_newline;
											}
											else if ($2->getName() == "/")
											{
												my_code = $1->getCode() + $3->getCode() + st_comment + my_tab + "XOR DX, DX" + my_newline + my_tab + "MOV AX, " + $1->getAsm_var() + my_newline + my_tab + "CWD";
												my_code = my_code + my_newline + my_tab + "MOV BX, " + $3->getAsm_var() + my_newline + my_tab + "DIV BX" + my_newline + my_tab + "MOV " + t + ", AX" + my_newline;
											}
											else if ($2->getName() == "%")
											{
												my_code = $1->getCode() + $3->getCode() + st_comment + my_tab + "MOV AX, " + $1->getAsm_var() + my_newline + my_tab + "CWD" + my_newline + my_tab + "XOR DX, DX";
												my_code = my_code + my_newline + my_tab + "MOV BX, " + $3->getAsm_var() + my_newline + my_tab + "DIV BX" + my_newline + my_tab + "MOV " + t + ", DX" + my_newline;
											}
											$$->setCode(my_code);
											$$->setAsm_var(t);

											cout<<"At line no: "<<line_count<<" term : term MULOP unary_expression"<<endl<<endl;
											cout<<$$->getName()<<endl<<endl;
										 }
     ;

unary_expression : ADDOP unary_expression  
											{
												$$ = new symbolInfo($1->getName() + $2->getName(), "non_terminal");
												$$->setVar_type($2->getVar_type());
												$$->setFunc_return_type($2->getFunc_return_type());
												logfile<<"Line "<<line_count<<": unary_expression : ADDOP unary_expression"<<endl<<endl;
												string st_comment = my_tab + ";Line " + to_string(line_count) + ": !" + $2->getName() + my_newline + my_newline;
												if ($2->getVar_type() == "function")
												{
													if ($2->getFunc_return_type() == "void" )
													{
														error_count++;
														errorfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
														logfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
													}
												}
												logfile<<$$->getName()<<endl<<endl;

												if ($1->getName() == "+")
												{
													$$->setAsm_var($2->getAsm_var());
													$$->setCode($2->getCode());
												}
												else if($1->getName() == "-")
												{
													string t = newTemp();
													string t_data = t + " DW ?";
													data_seg.push_back(t_data);
													string my_code = $2->getCode() + st_comment + my_tab + "MOV AX, " + $2->getAsm_var() + my_newline + my_tab + "MOV " + t + ", AX" + my_newline;
													my_code = my_code + my_tab + "NEG " + t + my_newline;
													$$->setAsm_var(t);
													$$->setCode(my_code); 
												}
												cout<<"At line no: "<<line_count<<" unary_expression : ADDOP unary_expression"<<endl<<endl;
												cout<<$$->getName()<<endl<<endl;
											}

		 | NOT unary_expression 
		 							{
										$$ = new symbolInfo("!" + $2->getName(), "non_terminal");
										$$->setVar_type("int");
										$$->setFunc_return_type($2->getFunc_return_type());
										logfile<<"Line "<<line_count<<": unary_expression : NOT unary expression"<<endl<<endl;
										if ($2->getVar_type() == "function")
										{
											if ($2->getFunc_return_type() == "void" )
											{
												error_count++;
												errorfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
												logfile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
											}
										}
										logfile<<$$->getName()<<endl<<endl;

										string st_comment = my_tab + ";Line " + to_string(line_count) + ": !" + $2->getName() + my_newline + my_newline;
										string my_lab_1 = newLabel();
										string my_lab_2 = newLabel();
										string t = newTemp();
										string t_data = t + " DW ?";
										data_seg.push_back(t_data);
										string my_code = $2->getCode() + st_comment + my_tab + "MOV AX, " + $2->getAsm_var() + my_newline + my_tab + "CMP AX, 0" + my_newline + my_tab + "JE " + my_lab_1 + my_newline + my_tab + "MOV AX, 0" + my_newline + my_tab + "MOV " + t + ", AX" + my_newline + my_tab + "JMP " + my_lab_2 + my_newline;
										my_code = my_code + my_lab_1 + ":" + my_newline + my_tab + "MOV AX, 1" + my_newline + my_tab + "MOV " + t + ", AX" + my_newline + my_lab_2 + ":" + my_newline;
										$$->setAsm_var(t);
										$$->setCode(my_code);
										cout<<"At line no: "<<line_count<<" unary_expression : NOT unary expression"<<endl<<endl;
										cout<<$$->getName()<<endl<<endl;
									}

		 | factor 
		 			{
						$$ = $1;
						logfile<<"Line "<<line_count<<": unary_expression : factor"<<endl<<endl;
						logfile<<$$->getName()<<endl<<endl;
						cout<<"At line no: "<<line_count<<" unary_expression : factor"<<endl<<endl;
						cout<<$$->getName()<<endl<<endl; 
					}
		 ;

factor	: variable 
						{
							$$ = $1;
							logfile<<"Line "<<line_count<<": factor : variable"<<endl<<endl;
							logfile<<$$->getName()<<endl<<endl;
							cout<<"At line no: "<<line_count<<" factor : variable"<<endl<<endl;
							cout<<$$->getName()<<endl<<endl;
						}

	| ID LPAREN argument_list RPAREN
										{
											$$ = new symbolInfo($1->getName() + "(" + $3->getName() + ")", "non_terminal");
											logfile<<"Line "<<line_count<<": factor : ID LPAREN argument_list RPAREN"<<endl<<endl;
											cout<<"At line no: "<<line_count<<" factor : ID LPAREN argument_list RPAREN"<<endl<<endl;
											my_si = table->lookup($1->getName());
											if (my_si != NULL)
											{
												//errorfile<<my_si->getName()<<endl<<endl;
												if (my_si->getVar_type() == "function")
												{
													//errorfile<<my_si->getName()<<endl<<endl;
													$$->setVar_type(my_si->getVar_type());
													$$->setFunc_return_type(my_si->getFunc_return_type());
													$$->setFunc_parameters(my_si->getFunc_parameters());
													if (my_si->getDefined() == false)
													{
														error_count++;
														errorfile<<"Error at line "<<line_count<<": "<<my_si->getName()<<" declared but not defined before calling "<<endl<<endl;
														logfile<<"Error at line "<<line_count<<": "<<my_si->getName()<<" declared but not defined before calling "<<endl<<endl;
													}
													if (my_si->getFunc_parameters().size() != my_arguments.size())
													{
														//errorfile<<my_si->getFunc_parameters().size()<<"      "<<my_arguments.size()<<endl<<endl;
														error_count++;
														errorfile<<"Error at line "<<line_count<<": Total number of arguments mismatch in function "<<my_si->getName()<<endl<<endl;
														logfile<<"Error at line "<<line_count<<": Total number of arguments mismatch in function "<<my_si->getName()<<endl<<endl;
													}
													else
													{
														string s="";
														for(int i =0; i< my_si->getFunc_parameters().size(); i++)
														{
															if (my_arguments[i]->getVar_type() == "function")
																s = my_arguments[i]->getFunc_return_type();
															else
																s = my_arguments[i]->getVar_type();
															//errorfile<<my_si->getFunc_parameters()[i]<<" "<<my_arguments[i]->getVar_type()<<endl;
															if (my_si->getFunc_parameters()[i] != s && ty_mismatch == false)
															{
																if (my_si->getFunc_parameters()[i] == "float" && s == "int")
																;
																else
																{
																	error_count++;
																	errorfile<<"Error at line "<<line_count<<": "<<i+1<<"th argument mismatch in function "<<my_si->getName()<<endl<<endl;
																	logfile<<"Error at line "<<line_count<<": "<<i+1<<"th argument mismatch in function "<<my_si->getName()<<endl<<endl;
																	break;
																}
															}
														}
													}
												}
												else
												{
													error_count++;
													logfile<<"Error at line "<<line_count<<": type mismatch, "<<my_si->getName()<<" is not a function"<<endl<<endl;
													errorfile<<"Error at line "<<line_count<<": type mismatch, "<<my_si->getName()<<" is not a function"<<endl<<endl;
													$$->setVar_type("int");
												}
											}
											else
											{
												error_count++;
												errorfile<<"Error at line "<<line_count<<": Undeclared function "<<$1->getName()<<endl<<endl;
												logfile<<"Error at line "<<line_count<<": Undeclared function "<<$1->getName()<<endl<<endl;
												$$->setVar_type("int");
											}
											
											
											logfile<<$$->getName()<<endl<<endl;
											
											cout<<$$->getName()<<endl<<endl;
											for_func_name.clear();
											my_arguments.clear();
											ty_mismatch = false;

											string st_comment = my_tab + ";Line " + to_string(line_count) + ": Calling " + $1->getName() + "(" + $3->getName() + ")" + my_newline + my_newline;
											string my_code = "" + st_comment;
											string t = newTemp();
											string t_data = t + " DW ?";
											data_seg.push_back(t_data);
											if(arg_asm.size() != 0)
											{
												for(int i=0; i<arg_asm.size(); i++)
												{
													my_code = my_code + my_tab + "PUSH " + arg_asm[i] + my_newline;
												}
											}
											if (my_si != NULL)
											{
												if	(my_si->getVar_type() == "function")
												{
													if (my_si->getFunc_return_type() == "void")
													{
														my_code = my_code + my_tab + "CALL " + $1->getName() + my_newline;
													}
													else
													{
														my_code = my_code + my_tab + "CALL " + $1->getName() + my_newline + my_tab + "POP " + t + my_newline;
													}
												}
											}
											
											if(arg_asm.size() != 0)
											{
												for(int i=arg_asm.size() - 1; i>=0; i--)
												{
													my_code = my_code + my_tab + "POP AX" + my_newline + my_tab + "MOV " + arg_asm[i] + ", AX" + my_newline;
												}
											}
											arg_asm.clear();
											$$->setCode(my_code);
											$$->setAsm_var(t);
										}

	| LPAREN expression RPAREN
								{
									$$ = new symbolInfo("(" + $2->getName() + ")", "non_terminal");
									$$->setVar_type($2->getVar_type());
									$$->setCode($2->getCode());
									$$->setAsm_var($2->getAsm_var());
									logfile<<"Line "<<line_count<<": factor : LPAREN expression RPAREN"<<endl<<endl;
									logfile<<$$->getName()<<endl<<endl;
									cout<<"At line no: "<<line_count<<" factor : LPAREN expression RPAREN"<<endl<<endl;
									cout<<$$->getName()<<endl<<endl;
								}

	| CONST_INT 
					{
						ty_mismatch = false;
						$1->setVar_type("int");
						$1->setAsm_var($1->getName());
						$1->setCode("");
						$$ = $1;
						logfile<<"Line "<<line_count<<": factor : CONST_INT"<<endl<<endl;
						logfile<<$$->getName()<<endl<<endl;
						cout<<"At line no: "<<line_count<<" factor : CONST_INT"<<endl<<endl;
						cout<<$$->getName()<<endl<<endl;
					}

	| CONST_FLOAT
					{
						ty_mismatch = false;
						$1->setVar_type("float");
						$1->setCode($1->getName());
						$$ = $1;
						logfile<<"Line "<<line_count<<": factor : CONST_FLOAT"<<endl<<endl;
						logfile<<$$->getName()<<endl<<endl;
						cout<<"At line no: "<<line_count<<" factor : CONST_FLOAT"<<endl<<endl;
						cout<<$$->getName()<<endl<<endl;
					}

	| variable INCOP 
						{
							$$ = new symbolInfo($1->getName() + $2->getName(), "non_terminal");
							$$->setVar_type($1->getVar_type());
							logfile<<"Line "<<line_count<<": factor : variable INCOP"<<endl<<endl;
							logfile<<$$->getName()<<endl<<endl;

							string var_name = "";
							for(int i=0;i<$1->getName().length();i++)
							{
								if($1->getName()[i] != '[')
									var_name = var_name + $1->getName()[i];
								else
									break; 
							}
							my_si = table->lookup(var_name);
							string st_comment = my_tab + ";Line " + to_string(line_count) + ": " + $1->getName() + $2->getName() +my_newline + my_newline;
							string my_code = "";
							string t = newTemp();
							string t_data = t + " DW ?";
							data_seg.push_back(t_data);
							if(my_si != NULL)
							{
								if(my_si->getVar_type() == "array int" || my_si->getVar_type() == "array float")
								{
									my_code = $1->getCode() + st_comment + my_tab + "MOV AX, " + $1->getAsm_var() + my_newline + my_tab + "MOV " + t + ", AX" + my_newline;
									my_code = my_code + my_tab + "INC " + $1->getAsm_var() + my_newline;
								}
								else
								{
									my_code = $1->getCode() + st_comment + my_tab + "MOV AX, " + $1->getAsm_var() + my_newline + my_tab + "MOV " + t + ", AX" + my_newline;
									my_code = my_code + my_tab + "INC " + $1->getAsm_var() + my_newline;
								}
							}
							$$->setCode(my_code);
							$$->setAsm_var(t);

							cout<<"At line no: "<<line_count<<" factor : variable INCOP"<<endl<<endl;
							cout<<$$->getName()<<endl<<endl;
						}

	| variable DECOP
						{
							$$ = new symbolInfo($1->getName() + $2->getName(), "non_terminal");
							$$->setVar_type($1->getVar_type());
							logfile<<"Line "<<line_count<<": factor : variable DECOP"<<endl<<endl;
							logfile<<$$->getName()<<endl<<endl;

							string var_name = "";
							for(int i=0;i<$1->getName().length();i++)
							{
								if($1->getName()[i] != '[')
									var_name = var_name + $1->getName()[i];
								else
									break; 
							}
							my_si = table->lookup(var_name);
							string my_code = "";
							string st_comment = my_tab + ";Line " + to_string(line_count) + ": " + $1->getName() + $2->getName() + my_newline + my_newline;
							string t = newTemp();
							string t_data = t + " DW ?";
							data_seg.push_back(t_data);
							if(my_si != NULL)
							{
								if(my_si->getVar_type() == "array int" || my_si->getVar_type() == "array float")
								{
									my_code = $1->getCode() + st_comment + my_tab + "MOV AX, " + $1->getAsm_var() + my_newline + my_tab + "MOV " + t + ", AX" + my_newline;
									my_code = my_code + my_tab + "DEC " + $1->getAsm_var() + my_newline;
								}
								else
								{
									my_code = $1->getCode() + st_comment + my_tab + "MOV AX, " + $1->getAsm_var() + my_newline + my_tab + "MOV " + t + ", AX" + my_newline;
									my_code = my_code + my_tab + "DEC " + $1->getAsm_var() + my_newline;
								}
							}
							$$->setCode(my_code);
							$$->setAsm_var(t);

							cout<<"At line no: "<<line_count<<" factor : variable DECOP"<<endl<<endl;
							cout<<$$->getName()<<endl<<endl;
						}
	;		 	 		  				 	   	 				  	   

argument_list : arguments
							{
								$$ = $1;
								logfile<<"Line "<<line_count<<": argument_list : arguments"<<endl<<endl;
								logfile<<$$->getName()<<endl<<endl;
								cout<<"At line no: "<<line_count<<" argument_list : arguments"<<endl<<endl;
								cout<<$$->getName()<<endl<<endl;
							}
			  |				
			  				{
								$$ = new symbolInfo("","non_terminal");
								logfile<<"Line "<<line_count<<": argument_list : "<<endl<<endl;
								logfile<<$$->getName()<<endl<<endl;
								cout<<"At line no: "<<line_count<<" argument_list : "<<endl<<endl;
								cout<<$$->getName()<<endl<<endl;
							}
			  ;
	
arguments : arguments COMMA logic_expression
												{
													arg_asm.push_back($3->getAsm_var());
													my_arguments.push_back($3);
													$$ = new symbolInfo($1->getName() + "," + $3->getName(), "non_terminal");
													logfile<<"Line "<<line_count<<": arguments : arguments COMMA logic_expression"<<endl<<endl;
													logfile<<$$->getName()<<endl<<endl;
													cout<<"At line no: "<<line_count<<" arguments : arguments COMMA logic_expression"<<endl<<endl;
													cout<<$$->getName()<<endl<<endl;
												}
	      | logic_expression
		  						{
									arg_asm.push_back($1->getAsm_var());
									my_arguments.push_back($1);
									$$ = $1;
									logfile<<"Line "<<line_count<<": arguments : logic_expression"<<endl<<endl;
									logfile<<$$->getName()<<endl<<endl;
									cout<<"At line no: "<<line_count<<" arguments : logic_expression"<<endl<<endl;
									cout<<$$->getName()<<endl<<endl;
								}

	      ;

%%
int main(int argc,char *argv[])
{

	/*if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}*/

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open Input file\n");
		return 0;
	}

	/*fp2= fopen(argv[2],"w");
	fclose(fp2);
	fp3= fopen(argv[3],"w");
	fclose(fp3);
	
	fp2= fopen(argv[2],"a");
	fp3= fopen(argv[3],"a");*/
	
	logfile.open("log.txt",ios::out);
	errorfile.open("error.txt",ios::out);
	codefile.open("code.asm",ios::out);
	o_codefile.open("optimized_code.asm",ios::out);

	//logfile<<"opended file"<<endl;
	//errorfile<<"opended file"<<endl;
	//vec_var.resize(1000);
	my_parameters.resize(0);
	table = new symbolTable(30);

	yyin=fin;
	yyparse();
	

	//fclose(fp2);
	//fclose(fp3);
	fclose(yyin);
	logfile.close();
	errorfile.close();
	codefile.close();
	o_codefile.close();
	return 0;
}

