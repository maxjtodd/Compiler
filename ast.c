/*
Lab9 ast.c
Max Todd
4/26/21
Provides function definitions for ASTnode, Provides the means to produce a abstract syntax tree, to create nodes and print out the contents.
*/

#include <stdlib.h>
#include <stdio.h>
#include "ast.h"



// PRE: ASTtype, type of statement to be stored in the tree
// POST: * to ASTnode from heap with all links set to null, except for type as mytype
struct ASTnode * ASTCreateNode(enum AST_Type mytype) {
    
    // creating and allocating space for node
    struct ASTnode *p;
    p = (struct ASTnode *) malloc(sizeof(struct ASTnode));
    
    // sets member values to NULL or parameters
    p->type = mytype;
    p->operator = NOOP;
    p->size = 0;
    p->s1 = NULL;
    p->s2 = NULL;
    p->next=NULL;
    
    // return pointer to node created
    return p;
    
} // ASTCreateNode


// PRE:  howmany, amount of spaces to be printed
// POST: spaces printed howmany times
void PT(int howmany)
{
	 for (int i = 0; i < howmany; i++) {
         
         printf(" ");
         
    } // for
} // PT



// PRE: PTR to ASTnode to be printed, spaces to be printed
// POST: formatted output of the AST, printed recursively
void ASTprint(struct ASTnode *p, int spaces) {
    
    // check p for NULL
    if (p == NULL) return;
    
    
    switch(p->type) {
        
        // var dec
        case A_VARDEC:
            
            PT(spaces);
            
            // print vardec
            printf("Variable ");
            
            // print var type
            ASTprintType(p->operator, spaces);
            
            // print var name
            printf("%s",p->name);
            
            if (p->size > 0) 
                printf("[%d]", p->size);
            
            printf("\n");
            ASTprint(p->s1, spaces); // prints same line var declarations
            ASTprint(p->next,spaces); // prints further declarations            
            break;
        
        // function dec
        case A_FUNDEC:
            
            PT(spaces);
            
            // print function type
            ASTprintType(p->operator, spaces);
            
            
            printf("FUNCTION ");
            
            // print function name
            printf("%s\n", p->name);
            
            
            ASTprint(p->s1, spaces + 1); // prints params
            ASTprint(p->s2, spaces + 2); // prints compound statement
            ASTprint(p->next, spaces); // continues to print declarations
            break;
            
        // parameters
        case A_PARAMS:
            
            PT(spaces);
            
            printf("params ");
            
            // non void parameter
            if (p->operator != A_VOIDTYPE) {
                // print name
                printf("%s", p->name);
                // print array if array
                if (p->size == -1) 
                    printf("[]");
                
                printf(" of ");    
                ASTprintType(p->operator, spaces);
            }
            // void parameter
            else {
                printf("void");
            }
            
            printf("\n");
            
            ASTprint(p->next, spaces); 

            
            break;
            
            
        // compound statements
        case A_COMPOUNDSTMT:
            
            PT(spaces);
            
            printf("compound statement: BEGIN\n");
            
            // no lodcal declarations
            if (p->s1 == NULL) {
                
                PT(spaces + 1);
                printf("(NO LOCAL DECLARATIONS)\n");
                
            }
            // local declarations present
            else {
                
                PT(spaces);
                printf(" (\n");
                ASTprint(p->s1, spaces + 1);
                PT(spaces);
                printf(" )\n");
                
            }

            ASTprint(p->s2, spaces + 2); // statement list
            
            
            PT(spaces);
            printf("compound statement: END\n");
            
            ASTprint(p->next, spaces);
            
            break;
            
            
        // local variable declarations
        case A_LOCALVARDEC:
            
            PT(spaces);
            
            printf("local vardec ");
            // print var type
            ASTprintType(p->operator, spaces);
            
            // print var name
            printf("%s",p->name);
            
            if (p->size > 0) 
                printf(" [%d]", p->size);
            
            printf("\n");   
            
            ASTprint(p->next, spaces);
            
            break;
        
        
        // if then, if then else
        case A_IFTHENSTMT:
            
            PT(spaces);
            
            // if then statement
            if (p->s2->type != A_IFTHENSTMT) {
                printf("IF THEN STATEMENT, IF\n");
                ASTprint(p->s1, spaces + 2); // prints expression
                PT(spaces + 1);
                printf("IF THEN STATEMENT, THEN\n");
                ASTprint(p->s2, spaces + 3); // prints then
            }
            // if then else statement
            else {
                printf("IF THEN ELSE STATEMENT, IF\n");
                ASTprint(p->s1, spaces + 2); // prints expression
                
                PT(spaces + 1);
                printf("IF THEN ELSE STATEMENT, THEN\n");
                ASTprint(p->s2->s1, spaces + 3); // prints then
                
                PT(spaces + 2);
                printf("IF THEN ELSE STATEMENT, ELSE\n");
                ASTprint(p->s2->s2, spaces + 4); // prints else
            }
            
            ASTprint(p->next, spaces); 
            break;
        
        
        // while
        case A_ITERATIONSTMT:
            
            PT(spaces);
            
            printf("WHILE STATEMENT\n");
            ASTprint(p->s1, spaces + 1); // prints expression 
            ASTprint(p->s2, spaces + 2); // prints statement
            ASTprint(p->next, spaces); // prints further statements
            break;
            
            
        // assignment
        case A_ASSIGNMENTSTMT:
            
            PT(spaces);
            
            printf("ASSIGNMENT STATEMENT\n");
            ASTprint(p->s1, spaces + 1); // prints var thats being assigned
            ASTprint(p->s2, spaces + 2); // prints simple expression
            ASTprint(p->next, spaces); // prints further statements
            break;
        
            
        // return
        case A_RETURNSTMT: 
            
            PT(spaces);
            
            printf("RETURN STATEMENT\n");
            ASTprint(p->s1, spaces + 1); // prints parameter
            
            ASTprint(p->next, spaces); // prints further statements
            break;
            
            
        // read
        case A_READSTMT:
            
            PT(spaces);
            
            printf("READ STATEMENT\n");
            ASTprint(p->s1, spaces + 1); // prints parameter
            ASTprint(p->next, spaces); // prints further statements
            break;
            
            
        // write
        case A_WRITESTMT:
            
            PT(spaces);
            
            // write a quoted string
            if(p->name != NULL) {
                
                printf("WRITE QUOTED STRING: %s\n", p->name);
                
            } // end if
            
            // write an expression
            else {
                
                printf("WRITE STATEMENT\n");
                ASTprint(p->s1, spaces + 1); // prints parameter
                
            } // end else
            
            ASTprint(p->next, spaces); // prints further statments
            break;
            
            
        // using a var
        case A_VAR:
            
            PT(spaces);
            
            printf("IDENTIFIER %s\n", p->name); // print var and var name
            
            // if var is an array reference, print array reference information
            if (p->s1 != NULL) { 
                PT(spaces);
                printf("Array Reference [\n");
                ASTprint(p->s1, spaces + 1);
                PT(spaces);
                printf("] end array\n");
            }
            
            break;
            
            
        // number
        case A_NUM:
            
            PT(spaces);
            
            printf("NUM, value: %d\n",p->size);
            break;
            
            
        // expression
        case A_EXPR:
            
            PT(spaces);
            
            // print expression and op
            printf("Expression ");             
            ASTprintType(p->operator, spaces);
            printf("\n");
            
            ASTprint(p->s1, spaces + 1); // links to itself
            ASTprint(p->s2, spaces + 1); // links to term or factor
        
            break;
            
            
        // call a function
        case A_CALL:
            
            PT(spaces);
            
            printf("CALL %s\n", p->name);
            ASTprint(p->s1, spaces + 1); // prints args
            ASTprint(p->next, spaces); // prints further statements
            break;
            
            
        // arguments
        case A_ARGS: 
            
            PT(spaces);
            
            printf("ARGS\n");
            PT(spaces);
            
            printf("(\n");
            
            // print all args
            while (p != NULL) {
                
                ASTprint(p->s1, spaces + 1); // prints expression
                p = p->next; // point to the next args node
                
            }
            
            PT(spaces);
            printf(")\n");

            break;
            
            
        // booleans
        case A_BOOLEAN:
            
            PT(spaces);
            
            printf("BOOLEAN ");
            
            // booleans set to 1 if true, 0 if false
            if (p->size > 0)
                printf("true");
            else
                printf("false");
            
            printf("\n");
            
            break;
            
        
        // semicolons without statement
        case A_EXPRESSIONSTMT:
            ASTprint(p->s1, spaces);
            ASTprint(p->next, spaces); // print next statement, used for semicolons without a statement attached with it.
            break;
            
        
        default:
            fprintf(stderr,"WARNING WARNING UNKOWN TYPE IN ASTprint\n");
            fprintf(stderr,"FIX FIX FIX FIX FIX\n");
            break;
        
    } // switch
    
} // ASTprint






// PRE: enum OPERATORS to print, int spaces to get printed
// POST: printed operator for operator provided
void ASTprintType(enum OPERATORS myoperator, int spaces) {
    
    switch(myoperator) {
        
        case A_INTTYPE:
            printf("INT ");
            break;
        case A_BOOLTYPE:
            printf("boolean ");
            break;
        case A_VOIDTYPE:
            printf("void ");
            break;
        case A_PLUS:
            printf("+ ");
            break;
        case A_MINUS:
            printf("- ");
            break;
        case A_MULTIPLY:
            printf("* ");
            break;
        case A_DIVIDE:
            printf("/ ");
            break;
        case A_AND:
            printf("AND");
            break;
        case A_OR:
            printf("OR");
            break;
        case A_LESSEQUAL:
            printf("<=");
            break;
        case A_LESS:
            printf("<");
            break;
        case A_GREATER:
            printf(">");
            break;
        case A_GREATEREQUAL:
            printf(">=");
            break;
        case A_EQUAL:
            printf("==");
            break;
        case A_NOTEQUAL:
            printf("!=");
            break;
        case A_NOT:
            printf("!");
            break;
        
        default:
            fprintf(stderr,"WARNING WARNING UNKOWN OPERATOR ENUM IN ASTprintType\n");
            fprintf(stderr,"FIX FIX FIX FIX FIX\n");
        
    } // switch
    
} // ASTprintType

