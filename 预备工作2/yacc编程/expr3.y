%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC file
**********************************************/

#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include <string.h>
#include<assert.h>
#ifndef YYSTYPE
#define YYSTYPE double
#define MAX_SYMBOLS 1024
#endif
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}

//TODO:给每个符号定义一个单词类别
%token IDENT
%token ADD MINUS
%token MUL DIV
%token L_PAREN R_PAREN
%token NUMBER
%left ADD MINUS
%left MUL DIV
%right UMINUS      

%%



lines   :       lines expr ';' { printf("%f\n", $2); }
        |       lines ';'
        |       stmt ';'
        ;
//TODO:完善表达式的规则
stmt    :       IDENT '=' expr {}
        |       expr    {$$=$2;}
        ;

expr    :       expr ADD expr   { $$=$1+$3; }
        |       expr MINUS expr   { $$=$1-$3; }
        |       expr MUL expr   { $$=$1*$3; }
        |       expr DIV expr   { $$=$1/$3; }
        |       L_PAREN expr R_PAREN    { $$=$2;}
        |       MINUS expr %prec UMINUS   {$$=-$2;}
        |       NUMBER  {$$=$1;}
        |       IDENT '=' expr { printf("=%f\n", $2); }
        |       IDENT {$$=$1; printf("%s",$1);}
        ;

%%

// programs section

/*
static struct string{
    char*str;
    int len;
    struct string *link;
} *buckets[1024];

 struct table{
    struct string *lexptr;
    string symbol;
 } tb;

 string lookup(string str,table t)
 {
    t->
 }
*/
/*
char *stringn(const char*str,int len){
    int i;
    // unsigned int h;
    int h=0;
    const char *end;
    struct string *p;
    assert(str);
    // for(h=0,i=len,end=str;i>0;i--)
       // h=(h<<1)+scatter[*(unsigned char*)end++];
    // h &=NELEMS(buckets)-1;
    for(p=buckets[h];p;p->link) //搜索
        if(len==p->len){
            const char *s1=str;
            char *s2=p->str;
            do{
                if(s1==end)
                    return p->str;
            }while(*s1++==*s2++);
        }
    {
        static char*next,*strlimit; //创建
        if(len+1>=strlimit-next){//现有空间不够
            int n =len + 4*1024;
            next=alloca(n); //分配空间
            strlimit=next+n;
        }
        p->len=len;
        for(p->str=next;str<end;)
            *next++=*str++; //赋值字符串
        *next++=0;
        p->link=buckets[h]; //放入hash表
        buckets[h]=p;
        return p->str;
    }
}
*/
/*
struct Table {
	int level;
	Table previous;
	struct entry {
		struct symbol sym;
		struct entry *link;
	} *buckets[256];
	Symbol all;
}tp;

Symbol lookup(const char *name, Table tp) {
	struct entry *p;
	unsigned h = (unsigned long)name&(HASHSIZE-1);

	assert(tp);
	do
		for (p = tp->buckets[h]; p; p = p->link)
			if (name == p->sym.name)
				return &p->sym;
	while ((tp = tp->previous) != NULL);
	return NULL;
}

Symbol install(const char *name, Table *tpp, int level, int arena) {
	Table tp = *tpp;
	struct entry *p;
	unsigned h = (unsigned long)name&(HASHSIZE-1);

	assert(level == 0 || level >= tp->level);
	if (level > 0 && tp->level < level)
		tp = *tpp = table(tp, level);	 //新作用域
	NEW0(p, arena);
	p->sym.name = (char *)name;
	p->sym.scope = level;
	p->sym.up = tp->all;
	tp->all = &p->sym;
	p->link = tp->buckets[h];		//放入Hash表
	tp->buckets[h] = p;
	return &p->sym;
}
*/
/*
static struct string{
    char*str;
    int len;
    struct string *link;
} *buckets[1024];

int i = 0;

struct table {
	struct string *lexptr;
	char* symbol;
	struct table *link;
}*tb;



char* lookup( char * str)
{
    struct string *p;
	for(p=buckets[0];p;p=p->link) //搜索
         {  char *s1=str;
            char *s2=p->str;
            if(*s1==*s2)
                return s1;
            
}
	return NULL;
}

void initialize()
{
	tb->link = NULL;
	tb->symbol = NULL;
	tb->lexptr = buckets[0];
}

void insert(char* str,char* sym)
{
	buckets=str;

	table *p = tb;
	if (p->symbol == "") {
		p->symbol = sym;
		p->link = NULL;
		p->lexptr = buckets[0];
	}
	else {
		while (p->link)
			p = p->link;
		table *tmp;
		tmp->symbol = sym;
		tmp->link = NULL;
		tmp->lexptr = buckets[i++];
		p->link = tmp;
	}	
	
}
*/

typedef struct {
    char name[20];
} Symbol;

Symbol symbolTable[MAX_SYMBOLS];
int numSymbols = 0;

// 查找符号表中的符号
int lookup(char* name) {
    for (int i = 0; i < numSymbols; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            return 1;
        }
    }
    return -1;  // 如果找不到符号，返回-1
}

// 向符号表中插入符号
void insert(char* name) {
    if (numSymbols >= MAX_SYMBOLS) {
        printf("符号表已满，无法插入新的符号\n");
        return;
    }
    
    strcpy(symbolTable[numSymbols].name, name);
    numSymbols++;
}

int yylex()
{
    char t;
    char lexbuff[100];
    while(1){
        t=getchar();
        if(t==' '||t=='\t'||t=='\n'){
            //do noting
        }else if(isdigit(t)){
            //TODO:解析多位数字返回数字类型
            yylval=0;
            while(isdigit(t)){
                yylval=yylval*10+t-'0';
                t=getchar();
            }
            ungetc(t,stdin);
            return NUMBER; 
        }else if(t=='+'){
            return ADD;
        }else if(t=='-'){
            return MINUS;
        }//TODO:识别其他符号
        else if(t=='*'){
            return MUL;
        }else if(t=='/'){
            return DIV;
        }else if(t=='('){
            return L_PAREN;
        }else if(t==')'){
            return R_PAREN;
        }else if(isalpha(t)){
            int n=0;
            while(isalpha(t)||isdigit(t)){
                lexbuff[n++]=t;
                t=getchar();
            }
            ungetc(t,stdin);
            lexbuff[n] = '\0';
            // int p=lookup(lexbuff);
           //  if(p==0)
              //  insert(lexbuff);
            yylval = atof(lexbuff);
            return IDENT;
        }
        else{
            return t;
        }
    }
}

int main(void)
{
    // initialize();
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
