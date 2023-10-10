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
#include<math.h>
int yylex();

int lookup(char *);
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);

//符号数据结构
struct symbol{
        char id[25];
        double value;
        int regno;
}; 



struct symbol symtab[100];

int count=0;
int regcount=0;
int numcount=0;
%}
//属性值具有的类型
%union{
    double  dval;
    struct symbol *sbl;
}



//TODO:给每个符号定义一个单词类别
%token <sbl> NUMBER
%token ADD MINUS 
%token MUL DIV 
%token LPAREN RPAREN
%token EQUAL
%token <sbl> IDENT

%right EQUAL
%left ADD MINUS
%left MUL DIV
%right UMINUS         

%type <sbl> expr

%%


lines   :       lines expr ';'// { printf("%f\n", $2); }
        |       lines ';'
        |
        ;
//TODO:完善表达式的规则
expr    :       expr ADD expr   { $$->value=($1->value)+($3->value); $$->regno=regcount++; printf("add r%d, r%d,r%d\n",$$->regno, $1->regno,$3->regno);}
        |       expr MINUS expr   { $$->value=$1->value-$3->value; $$->regno=regcount++; printf("sub r%d, r%d,r%d\n ",$$->regno,$1->regno,$3->regno);}
        |       expr MUL expr   { $$->value=$1->value*$3->value; $$->regno=regcount++; printf("mul r%d, r%d,r%d\n ",$$->regno, $1->regno,$3->regno);}
        |       expr DIV expr   { $$->value=$1->value/$3->value; $$->regno=regcount++; printf("div r%d, r%d, r%d\n ",$$->regno, $1->regno,$3->regno);}
        |       LPAREN expr RPAREN    { $$->value=$2->value; $$->regno=$2->regno;}
        |       MINUS expr %prec UMINUS   {$$->value=-$2->value;$$->regno=$2->regno;}
        |       NUMBER  {$$->value=$1->value; printf("mov r%d, #%d\n ",$1->regno, (int)round($1->value));}
        |       IDENT EQUAL expr  {$1->value=$3->value;$$->value=$3->value; printf("mov r%d, r%d\n ",$1->regno, $3->regno);}
        |       IDENT {$$->value=$1->value; $$->regno=$1->regno;}
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
            int tmp=0;
            while(isdigit(t)||t==' '||t=='\t'||t=='\n'){ 
                if(isdigit(t))
                    tmp=tmp*10+t-'0';
                t=getchar();
            }
            symtab[count].value=tmp;
                symtab[count].regno=regcount++;
                yylval.sbl=&symtab[count];
            count++;
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
                symtab[count].regno=regcount++;
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


