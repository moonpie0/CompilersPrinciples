#ifndef __MIN_DFA__
#define __MIN_DFA__

#include"dfa.h"
#include<set>
#include<iostream>
#include<map>
using namespace std;

class minDFANode{
public:   
    std::set<int> set;
    std::map<char,int> Next;
    int no;
    minDFANode(std::set<int> s){this->set=s;};
};

class MinDFA{
public:
    minDFANode* start;
    std::set<minDFANode*> end;
    set<int> end_no;
    std::vector<minDFANode*> NodeList;
    std::set<char>  charList;
    MinDFA(){}
};


void printSet(set<int> s)
{
    for(auto i : s)
    {
        printf("%d ",i);
    }
    printf("\n");
}



MinDFA* minDFA(DFA*dfa)
{
    std::vector<std::set<int>> minNode;
    std::vector<std::map<char,int>> NextList;


    int *label=new int[dfa->NodeList.size()]; //标签，相同标签的在同一组
    int count=0;
    std::set<int> s,e;
    for(auto node:dfa->NodeList)
    {
        std::map<char,int> tmp;
        for(auto next: node->Next)
        {
            tmp[next.first]=next.second->no;
        }
        NextList.push_back(tmp);
        if(!dfa->end.count(node))
        {
            s.insert(node->no);
            label[node->no]=count;
        }           
        else
        {
            e.insert(node->no);
            label[node->no]=count+1;
        }
            
    }
    minNode.push_back(s);
    minNode.push_back(e);

    count=2;
    
    int num=0;
    bool modified=false;
    for(int i=0;i<minNode.size() && num<3 ;i++) //遍历每个集合，三次未改变分组则停止
    {
        
        if(minNode[i].size()==1)
            continue;
        bool isdifferent=false;
        modified=false;
        set<int> diff;
        for(auto c:dfa->charList) //每个下一条路
        {

            int diff_label=-2;
            int curlabel=label[NextList[*(minNode[i].begin())][c]];
            for(auto node:minNode[i]) //集合中的每个点
            {
                if(diff_label==label[NextList[node][c]])
                    diff.insert(node);
                if(curlabel!=label[NextList[node][c]])
                {
                        //label[node]=count++;
                        isdifferent=true;
                        diff.insert(node);
                        diff_label=label[NextList[node][c]];
                }
            }

        }
        if(isdifferent)
        {
            for(auto k: diff)
                label[k]=count;
            count++;
            set<int> s1,s2;
            s1.insert(diff.begin(),diff.end());
            minNode.push_back(s1);
            s2.insert(minNode[i].begin(),minNode[i].end());
            for(auto j:s2)
            {
                if(s1.count(j))
                    s2.erase(j);
            }
            minNode.push_back(s2);
            std::vector<std::set<int>> ::iterator it=minNode.begin()+i;
            minNode.erase(it);
            modified=true;
            i--;
        }    
        if(modified)
            num=0;
        else
            num++;
        if(i+1==minNode.size())
            i=0;
    }

    MinDFA *mindfa=new MinDFA();
    for(auto i:minNode)
    {
        bool nsne=true;
        minDFANode * node=new minDFANode(i);
        if(i.count(dfa->start->no))
        {
            mindfa->start=node;
            nsne=false;
        }
            
        for(auto e:dfa->end)
        {
            if(i.count(e->no))
            {
                mindfa->end.insert(node);
                nsne=false;
            }           
        }
        if(nsne)
            mindfa->NodeList.push_back(node);
    }
    mindfa->NodeList.insert(mindfa->NodeList.begin(),mindfa->start);
    for(auto e:mindfa->end)
        mindfa->NodeList.push_back(e);
    for(int i=0;i<mindfa->NodeList.size();i++)
    {
        mindfa->NodeList[i]->no=i;
        if(mindfa->end.count(mindfa->NodeList[i]))
            mindfa->end_no.insert(i);
    }



    for(auto i:mindfa->NodeList)
    {
        for(auto c:dfa->charList)
        {
            for(auto j:mindfa->NodeList)
            {
                if(j->set.count(NextList[*(i->set.begin())][c]))
                    i->Next[c]=j->no;
                else if(NextList[*(i->set.begin())][c]==0)
                    i->Next[c]=-1;
            }           
        }
    }
    mindfa->charList=dfa->charList;
    return mindfa; 
}


void printminDFA(MinDFA * dfa)
{
    int count=0;
    printf("\n----------------------MinDFA START----------------------\n");
    for(auto node:dfa->NodeList)
    {
        for(auto c:dfa->charList)
        {
            if(node->Next[c]==-1)
                continue;

            if(dfa->end.count(node))
                printf("【%c】--%c--> ", node->no+65,c);
            else
                printf(" [%c] --%c--> ", node->no+65,c);
            if(dfa->end_no.count(node->Next[c]))
                printf("【%c】\n", node->Next[c]+65);  
            else
                printf(" [%c]\n", node->Next[c]+65);  
        }
        count++;
        printf("\n");
    }
    printf("-----------------------MinDFA END-----------------------\n");
}



#endif




