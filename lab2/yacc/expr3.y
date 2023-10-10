%{
/*********************************************
在2的基础上，实现功能更强的词法分析和语法分析程序使之能支持变量，修改词法分析程序，
能识别变量 (标识符) 和“=”符号，修改语法分析器，使之能分析、翻译“a=2形式的(或更复杂的，“a=表达式”) 赋值语句，
当变量出现在表达式中时，能正确获取其值进行计算(未赋值的变量取0)。当然，这些都需要实现符号表功能。
YACC file
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include <string.h>
int yylex();

int lookup(char *);
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);

//符号数据结构
struct symbol{
        char id[25];
        double value;
}; 
struct symbol symtab[10];

int count=0;
%}
//属性值具有的类型
%union{
    double  dval;
    struct symbol *sbl;
}



//TODO:给每个符号定义一个单词类别
%token <dval> NUMBER
%token ADD MINUS 
%token MUL DIV 
%token LPAREN RPAREN
%token EQUAL
%token <sbl> IDENT

%right EQUAL
%left ADD MINUS
%left MUL DIV
%right UMINUS         

%type <dval> expr

%%


lines   :       lines expr ';' { printf("%f\n", $2); }
        |       lines ';'
        |
        ;
//TODO:完善表达式的规则
expr    :       expr ADD expr   { $$=$1+$3; }
        |       expr MINUS expr   { $$=$1-$3; }
        |       expr MUL expr   { $$=$1*$3; }
        |       expr DIV expr   { $$=$1/$3; }
        |       LPAREN expr RPAREN    { $$=$2;}
        |       MINUS expr %prec UMINUS   {$$=-$2;}
        |       NUMBER  {$$=$1;}
        |       IDENT EQUAL expr  {$1->value=$3;$$=$3; printf("%s=",$1->id);}
        |       IDENT {$$=$1->value; }
        ;


%%

// programs section

int lookup(char * id){
    for(int i=0;i<count;i++){
        if(strcmp(id,symtab[i].id)==0)
                return i; 
    }
    return count;
}

int yylex()
{
    int t;
   char lexbuff[25];
    while(1){
        t=getchar();
        if(t==' '||t=='\t'||t=='\n'){
            //do noting 
        }else if(isdigit(t)){
            //TODO:解析多位数字返回数字类型
            yylval.dval=0;
            while(isdigit(t)||t==' '||t=='\t'||t=='\n'){ 
                if(isdigit(t))
                    yylval.dval=yylval.dval*10+t-'0';
                t=getchar();
            }
            ungetc(t,stdin);
            return NUMBER; 
        }       
        else if(isalpha(t)){ // 字母开头，字母和数字组成
            int n=0;
            while(isalpha(t)||isdigit(t)){
                lexbuff[n++]=t;
                t=getchar();
            }
            ungetc(t,stdin);
            lexbuff[n] = '\0';
            int index=lookup(lexbuff);
            if(index==count){
                strcpy(symtab[count].id,lexbuff);
                symtab[count].value=0;
                count++;
            };    
            yylval.sbl=&symtab[index];
            return IDENT;
        }
        else if(t=='+'){ 
            return ADD;
        }else if(t=='-'){
            return MINUS;
        }// TODO:识别其他符号
        else if(t=='*'){ 
            return MUL;
        }else if(t=='/'){ 
            return DIV;
        }else if(t=='('){  
            return LPAREN;
        }else if(t==')'){ 
            return RPAREN;
        } else if(t=='='){
            return EQUAL;
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


