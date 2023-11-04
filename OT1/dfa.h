#ifndef __DFA__
#define __DFA__

#include"nfa.h"
#include<map>
#include<vector>
#include<set>
using namespace std;
/*--------------------------DFA-----------------------------*/



class DFANode{
public:   
    std::set<Node*> set;
    std::map<char,DFANode*> Next;
    int no;
    DFANode(std::set<Node*> set){this->set=set;};
};

class DFA{
public:
    DFANode* start;
    std::set<DFANode*> end;
    std::vector<DFANode*> NodeList;
    std::set<char>  charList;
    DFA(DFANode*s){start=s;NodeList.push_back(s);}
};

/*-------------------------------------------------------*/

bool isEqual(set<Node*>s1,set<Node*>s2)
{
    if (s1.size() != s2.size())
        return false;
    for(auto i:s1)
    {
        if(!s2.count(i))//找不到
            return false;
    }
    return true;
}


DFA * NFA2DFA(NFA * nfa)
{
    DFANode* s=new DFANode(nfa->start->closure);
    DFA * dfa=new DFA(s);
    if(s->set.count(nfa->end)) //如果该DFA节点包含NFA的终态，则加入到end集合中
        dfa->end.insert(s);
    std::vector<DFANode*>::iterator it=dfa->NodeList.begin();
    int count=0;

    for(int i=0;;i++)
    {
        for(auto c: nfa->charList)
        {
            std::set<Node*> tmp_closure;
            for(auto node: dfa->NodeList[i]->set)
            
            {
                //printf("因为没有next对吧");
                for(auto m:node->Next)
                {
                    
                    if(m.first==c)
                        //tmp.insert(node->Next[c]);
                        tmp_closure.insert(node->Next[c]->closure.begin(),node->Next[c]->closure.end());
                }
            }
            bool flag=true;
            for(auto cur:dfa->NodeList)
            {
                if(isEqual(tmp_closure,cur->set))
                {
                    flag=false;
                    dfa->NodeList[i]->Next[c]=cur;
                    break;
                }
            }
            if(flag && tmp_closure.size()>0) //非重复的成为DFA的新节点
            {
                //printf("加进去\n");
                DFANode * new_node=new DFANode(tmp_closure);
                //(*it)->Next[c]=new_node;
                dfa->NodeList[i]->Next[c]=new_node;
                dfa->NodeList.push_back(new_node);
                if(tmp_closure.count(nfa->end)) //如果该DFA节点包含NFA的终态，则加入到end集合中
                    dfa->end.insert(new_node);
            }
        }
        //it++;
        if(dfa->NodeList.size()==i+1)
            break;
    }
    dfa->charList=nfa->charList;
    return dfa;
}


void printDFA(DFA * dfa)
{
    int count=0;
    printf("\n----------------------DFA START----------------------\n");
    for(auto node:dfa->NodeList)
    {
        node->no=count;
        for(auto next:node->Next)
        {
            int c=0;
            for(auto cur:dfa->NodeList)
            {
                if(cur==next.second)
                {
                    cur->no=c;
                    break;
                }               
                c++;
            }
            if(dfa->end.count(node))
                printf("【%d】--%c--> ", count,next.first);
            else
                printf(" [%d] --%c--> ", count,next.first);
            if(dfa->end.count(next.second))
                printf("【%d】\n", c);  
            else
                printf(" [%d]\n", c);  
        }
        //std::cout<<endl;
        count++;
        printf("\n");
    }
    printf("-----------------------DFA END-----------------------\n");
}



#endif
