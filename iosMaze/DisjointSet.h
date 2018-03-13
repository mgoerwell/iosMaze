#ifndef __DISJOINTSET_H__
#define __DISJOINTSET_H__

class DisjointSet
{
public:
    DisjointSet(int setSize = 256);
    ~DisjointSet();
    
    int Find(int x);
    void UnionSets(int s1, int s2);
    
private:
    int *setArray;
};

#endif
