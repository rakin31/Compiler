#include<iostream>
#include<string>
#include<fstream>
#include <cstdlib>
#include<vector>
#include<list>
using namespace std;

class symbolInfo
{
    string name;
    string type;
    symbolInfo* next;
public:
    symbolInfo()
    {
        this->name="";
        this->type="";
        this->next=NULL;
    }

    symbolInfo(string n, string t)
    {
        this->name=n;
        this->type=t;
        this->next=NULL;
    }

    void setName(string n)
    {
        this->name=n;
    }

    void setType(string t)
    {
        this->type=t;
    }

    void setNext(symbolInfo* s)
    {
        this->next=s;
    }

    string getName()
    {
        return this->name;
    }

    string getType()
    {
        return this->type;
    }

    symbolInfo* getNext()
    {
        return this->next;
    }

    ~symbolInfo()
    {
        this->name="";
        this->type="";
        delete next;
    }
};

int hashf(string name, int total_buckets)
{
    int sum=0;
    for(int i=0;i<name.length();i++)
        sum=sum+name[i];
    return sum%total_buckets;
}

class scopeTable
{
    symbolInfo** si;
    scopeTable* parentScope;
    int n;
    string id;
    int c_no;
public:
    scopeTable(int n1)
    {
        si=new symbolInfo*[n1];
        for(int i=0;i<n1;i++)
        {
            si[i]= new symbolInfo();
            si[i]=NULL;
        }
        parentScope=NULL;
        n=n1;
        id="1";
        c_no=0;
        //cout<<"cons done"<<endl;
    }

    scopeTable(int n, scopeTable* p)
    {
        si = new symbolInfo*[n];
        for(int i=0;i<n;i++)
            si[i]=new symbolInfo();
        //parentScope=p;
        this->n=n;
        id="1";
        c_no=0;
    }

    void setID(string s)
    {
        this->id=s;
    }

    void setC_no(int x)
    {
        this->c_no=x;
    }

    string getID()
    {
        return this->id;
    }

    int getC_no()
    {
        return this->c_no;
    }

    void setParentscope(scopeTable* s)
    {
        this->parentScope=s;
    }

    scopeTable* getParentscope()
    {
        return this->parentScope;
    }

    symbolInfo* lookUp(string name,int i1=0)
    {
        //fstream f1;
        //f1.open("outputst.txt",std::ios_base::app);
        //f1.seekg(0,ios::end);
        int index;
        index = hashf(name,n);
        //cout<<index<<endl;
        if(si[index] == NULL)
            return NULL;
        if(si[index]->getName().compare(name) == 0)
        {
            if(i1==0)
            {
                //cout<<"Found in ScopeTable# "<<this->id<<" at position "<<index<<",0"<<endl<<endl;
                //f1<<"Found in ScopeTable# "<<this->id<<" at position "<<index<<",0"<<endl<<endl;
            }

            return si[index];
        }

        symbolInfo* s=new symbolInfo();
        s=si[index];
        int i=1;
        while(s->getNext() != NULL)
        {
            s=s->getNext();
            if(s->getName().compare(name) == 0)
            {
                if(i1==0)
                {
                    //cout<<"Found in ScopeTable# "<<this->id<<" at position "<<index<<","<<i<<endl<<endl;
                    //f1<<"Found in ScopeTable# "<<this->id<<" at position "<<index<<","<<i<<endl<<endl;
                }

                return s;
            }
            i++;
        }
        return NULL;
        //f1.close();
    }

    bool insert(string name, string type)
    {
        fstream f1;
        f1.open("outputst.txt",std::ios_base::app);
        f1.seekg(0,ios::end);
        if(lookUp(name,1) != NULL)
            return false;
        symbolInfo* a=new symbolInfo(name,type);
        int index;
        index=hashf(name,n);
        if(si[index] == NULL)
        {
            si[index]=a;
            //cout<<"Inserted in ScopeTable# "<<id;
            //cout<<" at position "<<index<<", 0"<<endl<<endl;
            f1<<"Inserted in ScopeTable# "<<id;
            f1<<" at position "<<index<<", 0"<<endl<<endl;
            return true;
        }
        //cout<<name<<endl;
        symbolInfo* s=new symbolInfo();
        s=si[index];
        int i=1;
        while(s->getNext() != NULL)
        {
            s=s->getNext();
            i++;
        }

        s->setNext(a);
        //cout<<"Inserted in ScopeTable# "<<id;
        //cout<<" at position "<<index<<", "<<i<<endl<<endl;
        f1<<"Inserted in ScopeTable# "<<id;
        f1<<" at position "<<index<<", "<<i<<endl<<endl;
        f1.close();
        //cout<<s->getName()<<endl;
        return true;
    }

    bool deleteSi(string name)
    {
        fstream f1;
        f1.open("outputst.txt",std::ios_base::app);
        f1.seekg(0,ios::end);
        if(lookUp(name) == NULL)
            return false;
        int index;
        index=hashf(name,n);
        if(si[index]->getNext() == NULL)
        {
            si[index]=NULL;
            //cout<<"Deleted Entry "<<index<<", 0 from current ScopeTable"<<endl<<endl;
            f1<<"Deleted Entry "<<index<<", 0 from current ScopeTable"<<endl<<endl;
            return true;
        }
        if(si[index]->getName().compare(name) == 0)
        {
            si[index]=si[index]->getNext();
            //cout<<"Deleted Entry "<<index<<", 0 from current ScopeTable"<<endl<<endl;
            f1<<"Deleted Entry "<<index<<", 0 from current ScopeTable"<<endl<<endl;
            return true;
        }
        symbolInfo* prev=new symbolInfo();
        symbolInfo* s=new symbolInfo();
        prev=si[index];
        s=si[index]->getNext();
        int i=1;
        while(s != NULL)
        {
            if(s->getName().compare(name) == 0)
            {
                prev->setNext(s->getNext());
                //cout<<"Deleted Entry "<<index<<", "<<i<<" from current ScopeTable"<<endl<<endl;
                f1<<"Deleted Entry "<<index<<", "<<i<<" from current ScopeTable"<<endl<<endl;
                return true;
            }
            prev=s;
            s=s->getNext();
        }
        f1.close();
    }

    void print(fstream& f)
    {
        //fstream f1;
        //f1.open("outputst.txt",std::ios_base::app);
        f.seekg(0,ios::end);
        //cout<<"ScopeTable # "<<id<<endl;
        f<<"ScopeTable # "<<id<<endl;
        for(int i=0;i<n;i++)
        {
            //cout<<i<<" --> ";

            if(si[i] == NULL)
            {
                //cout<<endl;
                ;
            }

            else
            {
                f<<" "<<i<<" --> ";
                symbolInfo* s=new symbolInfo();
                s=si[i];
                while(s != NULL)
                {
                    //cout<<"< "<<s->getName()<<" : "<<s->getType()<<" > ";
                    f<<"< "<<s->getName()<<" : "<<s->getType()<<"> ";
                    s=s->getNext();
                }
                //cout<<endl;
                f<<endl;
            }
        }
        //cout<<endl<<endl;
        f<<endl;
        //f1.close();
    }

    ~scopeTable()
    {
        if(si)
        {
            for(int i=0;i<n;i++)
                delete si[i];
            delete[] si;
        }

        //delete parentScope;
        n=0;
        id="";
        c_no=0;
    }
};

class symbolTable
{
    scopeTable* cs;
    int n;
public:
    symbolTable(int no_of_bucket)
    {
        n=no_of_bucket;
        cs=new scopeTable(n);
        cs->setParentscope(NULL);
        cs->setC_no(0);
        cs->setID("1");
    }

    scopeTable* getCs()
    {
        return this->cs;
    }

    void enterScope()
    {
        //fstream f;
        //f.open("outputlogfile.txt",std::ios_base::app);
        //f.seekg(0,ios::end);
        cs->setC_no(cs->getC_no()+1);
        scopeTable* ns=new scopeTable(n);
        ns->setParentscope(this->cs);
        this->cs=ns;
        cs->setID(cs->getParentscope()->getID()+"."+to_string(cs->getParentscope()->getC_no()));
        //f<<"New ScopeTable with id "<<giveid()<<" created"<<endl<<endl;
        //f.close();
    }

    void exitScope()
    {
        //this->cs=NULL;
        //fstream f;
        //f.open("outputlogfile.txt",std::ios_base::app);
        //f.seekg(0,ios::end);
        //f<<"ScopeTable with id "<<giveid()<<" removed"<<endl<<endl;
        //f.close();
        scopeTable* temp = this->cs->getParentscope();
        delete this->cs;
        this->cs = temp;
        //this->cs=cs->getParentscope();
    }

    bool insert(string name, string type)
    {
        return cs->insert(name,type);
    }

    bool remove(string name)
    {
        return cs->deleteSi(name);
    }

    symbolInfo* lookup(string name)
    {
        symbolInfo* s=new symbolInfo();
        scopeTable* st=new scopeTable(n);
        st=this->cs;
        while(st != NULL)
        {
            s=st->lookUp(name);
            if(s != NULL)
                return s;
            st=st->getParentscope();
        }
        return s;
    }

    void printCST(fstream& f)
    {
        cs->print(f);
    }

    void printAST(fstream& f)
    {
        scopeTable* st=new scopeTable(n);
        st=this->cs;
        while(st != NULL)
        {
            st->print(f);
            st=st->getParentscope();
        }
    }

    string giveid()
    {
        string s="";
        if(cs->getParentscope() == NULL)
        {
            s=cs->getID();
            return s;
        }
        s=cs->getID();
        return s;
    }

    ~symbolTable()
    {
        scopeTable* curr = this->cs;
        while (curr != NULL)
        {
            scopeTable* temp = curr;
            delete temp;
            curr = curr->getParentscope();
        }
        //delete cs;
        n=0;
    }
};

/*int main()
{
    fstream f1;
    f1.open("outputst.txt",ios::out);
    int bucket_no=0;
    fstream f;
    f.open("input.txt",ios::in | ios::out);
    f>>bucket_no;
    symbolTable* st=new symbolTable(bucket_no);
    while(!f.eof())
    {
        fstream f1;
        f1.open("outputst.txt",std::ios_base::app);
        f1.seekg(0,ios::end);
        string s="";
        f>>s;
        if(s == "I")
        {
            string name="";
            string type="";
            f>>name;
            f>>type;
            //cout<<s<<" "<<name<<" "<<type<<endl<<endl;
            f1<<s<<" "<<name<<" "<<type<<endl<<endl;
            f1.close();
            if(!st->insert(name,type))
            {
                fstream f1;
                f1.open("outputst.txt",std::ios_base::app);
                f1.seekg(0,ios::end);
                //cout<<"<"<<name<<","<<type<<">"<<" already exists in current ScopeTable"<<endl<<endl;
                f1<<"<"<<name<<","<<type<<">"<<" already exists in current ScopeTable"<<endl<<endl;
                f1.close();
            }

        }
        else if(s == "S")
        {
            //cout<<s<<endl<<endl;
            f1<<s<<endl<<endl;
            st->enterScope();
            //cout<<"New ScopeTable with id "<<st->giveid()<<" created"<<endl<<endl;
            f1<<"New ScopeTable with id "<<st->giveid()<<" created"<<endl<<endl;
        }
        else if(s == "P")
        {
            //cout<<s<<" ";
            f1<<s<<" ";
            string s1="";
            f>>s1;
            if(s1 == "A")
            {
                //cout<<s1<<endl<<endl<<endl;
                f1<<s1<<endl<<endl<<endl;
                f1.close();
                st->printAST();
            }
            else if(s1 == "C")
            {
                //cout<<s1<<endl<<endl<<endl;
                f1<<s1<<endl<<endl<<endl;
                f1.close();
                st->getCs()->print();
            }
        }
        else if(s == "L")
        {
            string name="";
            f>>name;
            //cout<<s<<" "<<name<<endl<<endl;
            f1<<s<<" "<<name<<endl<<endl;
            f1.close();
            if(!st->lookup(name))
            {
                fstream f1;
                f1.open("outputst.txt",std::ios_base::app);
                f1.seekg(0,ios::end);
                //cout<<"Not found"<<endl<<endl;
                f1<<"Not found"<<endl<<endl;
                //cout<<name<<" not found"<<endl<<endl;
                f1<<name<<" not found"<<endl<<endl;
                f1.close();
            }

        }
        else if(s == "E")
        {
            //cout<<s<<endl<<endl;
            f1<<s<<endl<<endl;
            //cout<<"ScopeTable with id "<<st->giveid()<<" removed"<<endl<<endl;
            f1<<"ScopeTable with id "<<st->giveid()<<" removed"<<endl<<endl;
            st->exitScope();
        }
        else if(s == "D")
        {
            //cout<<s<<" ";
            f1<<s<<" ";
            string name="";
            f>>name;
            //cout<<name<<endl<<endl;
            f1<<name<<endl<<endl;
            f1.close();
            if(!st->remove(name))
            {
                fstream f1;
                f1.open("outputst.txt",std::ios_base::app);
                f1.seekg(0,ios::end);
                //cout<<"Not found"<<endl<<endl;
                f1<<"Not found"<<endl<<endl;
                //cout<<name<<" not found"<<endl<<endl;
                f1<<name<<" not found"<<endl<<endl;
                f1.close();
            }

        }
        f1.close();
    }
    f.close();
    f1.close();
    return 0;
}*/

