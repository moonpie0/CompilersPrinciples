#ifndef __NFA__
#define __NFA__


#include<map>
#include<vector>
#include<set>
using namespace std;
enum NodeType{START,END,OTHER};
class Node{
public:   
    NodeType type;
    std::map<char,Node*> Next;
    std::map<char,Node*> Prev; 
    std::set<Node*> closure;//闭包
    int no; //标号，暂时用一下
    Node(NodeType t){type=t;};
};

class NFA{
public:
    Node* start;
    Node* end;
    std::vector<Node*> NodeList; //用来装节点
    std::set<char>  charList;
    NFA(Node*s,Node*e){start=s;end=e;}
    void setPrev();
};



/*------------------------NFA-------------------------------*/

NFA* createNFA(char c) //空串0或字母
{
    struct Node*s=new Node(START);
    Node*e=new Node(END);
    s->Next[c]=e;
    NFA* nfa=new NFA(s,e);
    nfa->NodeList.push_back(s);
    nfa->NodeList.push_back(e);
    return nfa;
}

NFA* andNFA(NFA*a,NFA*b)
{
    a->end->Next['0']=b->start; //用空串连接
    a->end->type=OTHER;
    b->start->type=OTHER;
    NFA* nfa=new NFA(a->start,b->end);

    for (auto x : a->NodeList)
		nfa->NodeList.push_back(x);
    for (auto x : b->NodeList)
		nfa->NodeList.push_back(x);

    return nfa;
}

NFA* orNFA(NFA*a,NFA*b)
{
    Node*s=new Node(START);
    Node*e=new Node(END);
    a->start->type=OTHER;
    b->start->type=OTHER;
    a->end->type=OTHER;
    b->end->type=OTHER;
    s->Next['0']=a->start;
    s->Next['1']=b->start;
    a->end->Next['0']=e;
    b->end->Next['1']=e;

    NFA* nfa=new NFA(s,e);
    nfa->NodeList.push_back(s);
    for (auto x : a->NodeList)
		nfa->NodeList.push_back(x);
    for (auto x : b->NodeList)
		nfa->NodeList.push_back(x);
    nfa->NodeList.push_back(e);
    return nfa;
}

NFA* repeatNFA(NFA*a)
{
    Node*s=new Node(START);
    Node*e=new Node(END);
    a->start->type=OTHER;
    a->end->type=OTHER;
    s->Next['0']=a->start;
    a->end->Next['0']=e;
    s->Next['1']=e; //0和1都是空串
    a->end->Next['1']=a->start;

    NFA* nfa=new NFA(s,e);
    nfa->NodeList.push_back(s);
    for (auto x : a->NodeList)
		nfa->NodeList.push_back(x);
    nfa->NodeList.push_back(e);

    return nfa;
}

void printNFA(NFA *nfa)
{
    int count=0;
    printf("\n----------------------NFA START----------------------\n");
    for(auto node:nfa->NodeList)
    {
        node->no=count;
        for(auto next:node->Next)
        {
            int c=0;
            for(auto cur:nfa->NodeList)
            {
                if(cur==next.second)
                {
                    cur->no=c;
                    break;
                }
                    
                c++;
            }
            if(next.first=='0'||next.first=='1')
                printf("[%d] --\\0--> [%d]\n", count,c);
                //std::cout<<"["<<count<<"] --\0--> ["<<c<<"]"<<std::endl;
            else
            {
                nfa->charList.insert(next.first);
                printf("[%d] --%c--> [%d]\n", count,next.first,c);
            }
                
        }
        //std::cout<<endl;
        count++;
        printf("\n");
    }
    printf("-----------------------NFA END-----------------------\n");

    //for(auto c:nfa->charList)
      //  printf("%c\n",c);
}


/*为转为DFA做准备*/

void NFA::setPrev( )
{
    for(auto node:this->NodeList)
    {
        for(auto next:node->Next)
        {
            next.second->Prev[next.first]=node;
        }
    }
}

void printPrev(NFA*nfa)
{
    printf("\n----------------------Prev----------------------\n");
    for(auto node:nfa->NodeList)
    {
        printf("Prev{%d}:",node->no);
        for(auto n:node->Prev)
        {
            printf("(%c,%d),",n.first,n.second->no);
        }
        printf("\n");
    }
    printf("\n----------------------Prev----------------------\n");
}

void printClosure(NFA*nfa)
{
    printf("\n----------------------CLOSURE----------------------\n");
    for(auto node:nfa->NodeList)
    {
        printf("closure{%d}:",node->no);
        for(auto n:node->closure)
        {
            printf("%d,",n->no);
        }
        printf("\n");
    }
    printf("\n----------------------CLOSURE----------------------\n");
}

void printC(set<Node*>closure)
{
    printf("\n----------------------CUR CLOSURE----------------------\n");
        for(auto n:closure)
        {
            printf("%d,",n->no);
        }
        printf("\n");
    printf("\n----------------------CURCLOSURE----------------------\n");
}

void Compute_closure(NFA * nfa)
{
    nfa->setPrev();
    //printPrev(nfa);
    int count=nfa->NodeList.size(); //NFA节点数量
    for(auto n:nfa->NodeList) //加上自己
        n->closure.insert(n);
    for(int i=count-1;i>=0;i--) //遍历节点
    {
        Node *node=nfa->NodeList[i];
        //printClosure(nfa);
        for(auto pn: node->Prev) //当前节点的前向指针
        {
            if(pn.first=='0'||pn.first=='1')
            {
                //pn.second->closure=node->closure; //前一个节点的闭包等于下一个节点闭包+下一个节点           
                //pn.second->closure.insert(pn.second);
                for(auto nextcloure: node->closure)
                    pn.second->closure.insert(nextcloure);
                pn.second->closure.insert(node);
            }
        }
    }  
    //算不对、再来一次好了
    //由于*算法会有往回指的路径，因此从后往前算闭包的时候会有遗漏
    for(int i=count-1;i>=0;i--) //遍历节点
    {
        Node *node=nfa->NodeList[i];
        //printClosure(nfa);
        for(auto pn: node->Prev) //当前节点的前向指针
        {
            if(pn.first=='0'||pn.first=='1')
            {
                //pn.second->closure=node->closure; //前一个节点的闭包等于下一个节点闭包+下一个节点           
                //pn.second->closure.insert(pn.second);
                for(auto nextcloure: node->closure)
                    pn.second->closure.insert(nextcloure);
                pn.second->closure.insert(node);
            }
        }
    }      
}


# endif