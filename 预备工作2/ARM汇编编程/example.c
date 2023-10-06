#include <stdio.h>
int n=0;
int i=2;
int f=1;


int jiecheng(int n, ){
while (i <= n){
f = f * i;
i = i + 1;
}
return f;
}

int main(){
scanf("%d", &n);
printf("%d\n", jiecheng(n));
return 0;
}