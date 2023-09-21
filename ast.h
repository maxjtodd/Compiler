/*
Lab9 ast.h
Max Todd
4/26/21
Provides definitions of Operators, AST_Types for the nodes, the ASTnode structure, as well as function declarations for ASTnode
*/

#ifndef AST_H
#define AST_H



enum OPERATORS {
    
    NOOP,
    A_INTTYPE,
    A_BOOLTYPE,
    A_VOIDTYPE,
    A_STRINGTYPE,
    A_PLUS,
    A_MINUS,
    A_MULTIPLY,
    A_DIVIDE,
    A_AND,
    A_OR,
    A_LESSEQUAL,
    A_LESS,
    A_GREATER,
    A_GREATEREQUAL,
    A_EQUAL,
    A_NOTEQUAL,
    A_NOT
    
}; // AST_operater


// enum to distinguish node type
enum AST_Type {
    
    A_VARDEC,
    A_FUNDEC,
    A_PARAMS,
    A_COMPOUNDSTMT,
    A_LOCALVARDEC,
    A_EXPRESSIONSTMT,
    A_IFTHENSTMT,
    A_IFBODY,
    A_ITERATIONSTMT,
    A_RETURNSTMT,
    A_READSTMT,
    A_WRITESTMT,
    A_ASSIGNMENTSTMT,
    A_VAR,
    A_NUM,
    A_EXPR,
    A_CALL,
    A_ARGS,
    A_BOOLEAN
    
}; // AST_Type


// define main structure of AST 
struct ASTnode {
    
    enum AST_Type type;
    char* name; // used for items with names if present, such as variable names or function names
    enum OPERATORS operator; // used for operators if present, such as +, -, /
    enum OPERATORS calculatedType;
    int size; // used for items with size if present, used to store numerical values if present. For var calls, size = -1 for arrays and size = 1 for scalars
    struct ASTnode *s1, *s2, *next; // tree structure for other nodes
    char* label; // used to store string variables
    
    struct SymbTab *symbol; // link to symbol in the symbol table
    
    
}; // ASTnode



// function declarations
struct ASTnode *ASTCreateNode(enum AST_Type mytype);
void ASTprint(struct ASTnode *p, int spaces);
void ASTprintType(enum OPERATORS myoperator, int spaces);



#endif // AST_H
