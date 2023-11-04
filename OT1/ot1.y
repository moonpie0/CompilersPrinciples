%{
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>
#include"min_dfa.h"
int yylex();
#ifndef YYSTYPE
#define YYSTYPE NFA*
#endif

int lookup(char *);
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);

%}

//TODO:给每个符号定义一个单词类别
%token ALPHA BLANK

%left '|'  


%%


lines   :   lines cfg '\n' { 
                                NFA* nfa= $2; 
                                printNFA(nfa); 
                                Compute_closure(nfa);
                                //printClosure(nfa);
                                DFA* dfa=NFA2DFA(nfa);
                                printDFA(dfa);
                                MinDFA * mindfa=minDFA(dfa);
                                printminDFA(mindfa);
                            }
        |   lines '\n'
        |
        ;
//TODO:完善表达式的规则

cfg     :   and '|' cfg { $$=orNFA($1,$3); }
        |   and     {$$=$1;}
        ;

and     :   expr and { $$=andNFA($1,$2);}
        |   expr    { $$=$1;}
        ;       

expr    :       expr '*'        { $$=repeatNFA($1);}
        |       '(' cfg ')'     {$$=$2;}
        |       ALPHA           {$$=$1; }
        |       BLANK           {$$=$1;}
        ;


%%

// programs section


int yylex()
{
    int t;
    while(1){
        t=getchar();
        if(t==' '||t=='\t'){
            //do noting 
        }else if(t=='\\'){ //空串
            t=getchar();
            if(t=='0')
            {
                yylval=createNFA('0');
                return BLANK;
            }
            else
            {
                ungetc(t,stdin);
                ungetc(t,stdin);
                return t;
            }
        }else if(isalpha(t)){     //字母      
            yylval=createNFA(t);
            //printf("%c",t);
            return ALPHA;
        }else{
            return t;
        }
    }
}




int main(void)
{
    yyin=stdin;
    do{
        yyparse();
    }while(!feof(yyin));
    return 0;
}


void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}


