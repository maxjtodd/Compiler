%{

/*
Lab9 CS370 lab9.y
Max Todd
4/26/21
Defines grammer rules for algol c, takes lex tokens, gives semantic action to grammer with creating an abstract syntax tree, type checking, a symbol table, and creates MIPS code
*/




	/* begin specs */
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "symtable.h"
#include "emit.h"



#define FUNCTION_MIN_SIZE 2

struct ASTnode * program = NULL; // global variable for beginning of abstract syntax tree


// vars from lex for line count and debugging
extern int mydebug;
extern int linecount;

// variable to track local and global variables
int level = 0;

// variable to track symbol table offset from activation record
int offset = 0;

// variable to hold temperary offset for symbol table
int goffset = 0;

// variable to hold maximum offset needed
int maxoffset = 0;


// gets called for syntax errors
void yyerror (s)  /* Called by yyparse on error */
     char *s;
{
  printf ("%s on line %d\n", s, linecount);
}

int yylex(); // prototype for yylex

%}
/*  defines the start symbol, what values come back from LEX and how the operators are associated  */



// declares the return types for tokens
%union {

    int value;
    char* string;
    struct ASTnode * astnode;
    enum OPERATORS operator;
    
} // union



// start grammer rules at rule P
%start program

%token <value> T_NUM // define the INTEGER token
%token <string> T_ID // define the VARIABLE token
%token <string> T_QUOTED_STRING // define the STRING token

%token T_BEGIN T_END T_OF // define keyword tokens
%token T_RETURN T_READ T_WRITE // define statement tokens
%token T_IF T_THEN T_ELSE // if statement tokens
%token T_INT T_VOID T_BOOLEAN // define varaiable type tokens
%token T_TRUE T_FALSE T_NOT // define boolean tokens
%token T_WHILE T_DO // define iteration tokens
%token T_LESSEQUAL T_LESS T_GREATER T_GREATEREQUAL T_EQUAL T_NOTEQUAL // define relation operator tokens
%token T_AND T_OR


// declare nodes that return a node for the tree
%type <astnode> declaration_list declaration var_declaration var_list fun_declaration params param_list param compound_stmt local_declarations
%type <astnode> statement_list statement return_stmt read_stmt write_stmt assignment_stmt iteration_stmt selection_stmt expression_stmt expression simple_expression additive_expression term factor var call args arg_list

// declare the nodes that return an operator for a component in the tree
%type <operator> type_specifier adop multop relop


// define math operator tokens
%left '|'
%left '&'
%left '+' '-'
%left '*' '/' '%'
%left UMINUS




%%	/* end specs, begin rules */



// start rules by starting out with variable declarations, then going to list
program             :   declaration_list    {   program = $1; 
                                                //maxoffset = maxoffset + (offset - goffset);
                                            }
                    ;

                    
                    
// all declarations, next connected
declaration_list    :   declaration                  { $$ = $1;}

                    |   declaration declaration_list {$$ = $1;
                                                      $1->next = $2; 
                                                      
                                                      
                                                      
                                                     } // declist dec 
                    ;
                    
                    
                    
// declarations for variables or functions
declaration         : var_declaration {$$ = $1;}
                    | fun_declaration {$$ = $1;}
                    ;

                    
                    
                    
// declarations for variables
var_declaration     : type_specifier var_list ';' { $$ = $2;

                                                    struct ASTnode * p = $$;
                                                    
                                                    // pass operator, calculated type, and symbol table type to all coming vars that are declared in the case of multiple declarations with commas
                                                    while (p != NULL) {
                                                        
                                                        p->operator = $1;
                                                        p->calculatedType = $1;
                                                        p->symbol->Type = $1;
                                                        
                                                        p = p->s1;
                                                        
                                                    } // while
                                                  } // typespec varlist
                    ;
                    
                    
                    
                    
// forms for variable declarations
var_list            : T_ID                              {   // T_ID , single variable

                                                            // symbol not inserted, add to symbol table and add AST node
                                                            if (Search($1, level, 0) == NULL) {
                                                                
                                                                // create AST node
                                                                $$ = ASTCreateNode(A_VARDEC);
                                                                $$->name = $1;
                                                                $$->size = 1;
                                                                
                                                                // insert symbol into symbol table
                                                                $$->symbol = Insert($1,0,0,level,1,offset);
                                                                offset += 1;
                                                                
                                                                
                                                            }
                                                            // symbol is already inserted into symbol table, barf
                                                            else {
                                                                yyerror($1);
                                                                yyerror("symbol already used.");
                                                                exit(1);
                                                            }

                                                        } // T_ID
                                                        
                                                        
                    | T_ID '[' T_NUM ']'                {   // T_ID [ NUM ]  , single array variable
                    
                                                            // symbol not inserted, add to symbol table and add AST node
                                                            if (Search($1, level, 0) == NULL) {
                                                            
                                                                // create AST node
                                                                $$ = ASTCreateNode(A_VARDEC);
                                                                $$->name = $1;
                                                                $$->size = $3;
                                                                
                                                                // insert into symbol table
                                                                $$->symbol = Insert($1,0,2,level,$3,offset);
                                                                offset += $3;
                                                                
                                                            }
                                                            // symbol is already inserted into symbol table, barf
                                                            else {
                                                                yyerror($1);
                                                                yyerror("symbol already used.");
                                                                exit(1);
                                                            }
                                                            
                                                        } // T_ID [ NUM ] 
                                                        
                                                        
                                                        
                    | T_ID ',' var_list                 {   // multiple non array variable declaration
                                                            
                                                            // symbol not inserted, add to symbol table and add AST node
                                                            if (Search($1, level, 0) == NULL) {
                                                            
                                                                // create AST node
                                                                $$ = ASTCreateNode(A_VARDEC);
                                                                $$->name = $1;
                                                                $$->s1 = $3;
                                                                $$->size = 1;
                                                                
                                                                // insert symbol into symbol table
                                                                $$->symbol = Insert($1,0,0,level,1,offset);
                                                                offset += 1;
                                                                
                                                            }
                                                            // symbol is already inserted into symbol table, barf
                                                            else {
                                                                yyerror($1);
                                                                yyerror("symbol already used.");
                                                                exit(1);
                                                            }
                                                        } // T_ID , VARLIST
                                                        
                                                        
                                                        
                    | T_ID '[' T_NUM ']'',' var_list    {   // multiple array variable declaration
                            
                                                            // symbol not inserted, add to symbol table and add AST node
                                                            if (Search($1, level, 0) == NULL) {
                                                                // create AST node
                                                                $$ = ASTCreateNode(A_VARDEC);
                                                                $$->name = $1;
                                                                $$->size = $3;
                                                                $$->s1 = $6;
                                                                
                                                                // insert into symbol table
                                                                $$->symbol = Insert($1,0,2,level,$3,offset);
                                                                offset += $3;
                                                            }
                                                            // symbol is already inserted into symbol table, barf
                                                            else {
                                                                yyerror($1);
                                                                yyerror("symbol already used.");
                                                                exit(1);
                                                            }
                                                        } // T_ID [ T_NUM ] , VARLIST
                    ;

                    
                    
// type specifiers, returns operator
type_specifier      : T_INT         {$$ = A_INTTYPE;}
                    | T_VOID        {$$ = A_VOIDTYPE;}
                    | T_BOOLEAN     {$$ = A_BOOLTYPE;}
                    ;
                  
                  
                  
                  
// function declaration form, links to params with s1, links to compound statement with s2
fun_declaration     :   type_specifier 
                        T_ID 
                        '(' 
                        { 
                            // symbol not inserted, insert symbol into symbol table, reset offset and keep offset in global offset
                            if (Search($2,level,0) == NULL) {
                                Insert($2,$1,1,level,0,0);
                                goffset = offset;
                                offset = LOGWSIZE;
                                maxoffset = FUNCTION_MIN_SIZE;
                            }
                            // symbol already in use, barf
                            else {
                                yyerror($2);
                                yyerror("name already used.");
                                exit(1);
                            }
                        } // end symbol inserting
                        
                        params 
                        {
                            // update symbol table to have a pointer to formal parameters
                            (Search($2,0,0))->fparms = $5;
                        } // end formal parameter addition
                        
                        ')' 
                        compound_stmt 
                        {   
                             // create ASTnode 
                             $$ = ASTCreateNode(A_FUNDEC);
                             $$->name = $2;
                             $$->operator = $1;
                             $$->calculatedType = $1;
                             $$->s1 = $5; // params linked to s1
                             $$->s2 = $8; // compound statment linked to s2
                             
                             // insert into symbol table
                             $$->symbol = Search($2,level,0);
                             $$->symbol->mysize = maxoffset; // update function to size we need
                             
                             // correct offset
                             offset = goffset;

                        } // fun_declaration
                    ;

            
            
// parameter forms
params              : T_VOID            {   
                                            $$ = ASTCreateNode(A_PARAMS);
                                            $$->operator = A_VOIDTYPE;
                                            $$->calculatedType = A_VOIDTYPE;
                                        } // T_VOID
                                        
                    | param_list        {   // single or multiple params
                                            $$ = $1;
                                        } // param_list
                    ;

                    
                    
// parameter grammer, links to other parameters with next
param_list          : param                     {   // single parameter
                                                    $$ = $1;
                                                } // param
                                                
                    | param ',' param_list      { // multiple parameters, next connected
                                                    $$ = $1;
                                                    $1->next = $3; // links to other params
                                                } // param , param_list
                    ;
    
    
    
// parameter grammer, next connected
param               : T_ID T_OF type_specifier              {   // T_ID T_OF type_specifier  , non array parameter
                                                                
                                                                // symbol not in symbol table in compound statement
                                                                if (Search($1,level+1,0) == NULL) {
                                                                    // create AST node
                                                                    $$ = ASTCreateNode(A_PARAMS);
                                                                    $$->name = $1;
                                                                    $$->operator = $3;
                                                                    $$->calculatedType = $3;
                                                                    $$->size = 1;
                                                                    
                                                                    // insert symbol into symbol table
                                                                    $$->symbol = Insert($1,$3,0,level+1,1,offset);
                                                                    offset += 1;
                                                                } // end if
                                                                // symbol used improperly, barf
                                                                else {
                                                                    yyerror($1);
                                                                    yyerror("symbol already used.");
                                                                    exit(1);
                                                                }
                                                            } // T_ID T_OF type_specifier
                                                            
                                                            
                                                            
                                                            
                    | T_ID '[' ']' T_OF type_specifier      {   // array parameter, size is = -1
                    
                                                                // symbol not in symbol table in compound statement
                                                                if (Search($1,level+1,0) == NULL) {
                                                                    // create AST node
                                                                    $$ = ASTCreateNode(A_PARAMS);
                                                                    $$->name = $1;
                                                                    $$->operator = $5;
                                                                    $$->calculatedType = $5;
                                                                    $$->size = -1;
                                                                    
                                                                    // insert symbol into symbol table
                                                                    $$->symbol = Insert($1,$5,2,level+1,-1,offset);
                                                                    offset += 1;
                                                                }
                                                                // symbol used improperly, barf
                                                                else {
                                                                    yyerror($1);
                                                                    yyerror("symbol already used.");
                                                                    exit(1);
                                                                }
                                                                
                                                            } // T_ID [ ] T_OF type_specifier
                    ;

                    
                    
// compound statements, link to local declarations with s1 and statement list with s2, increment level for variable declarations
compound_stmt       : T_BEGIN   {level++;} // increment level for var declarations
                        local_declarations statement_list 
                      T_END                                             {
                                                                            // create AST node
                                                                            $$ = ASTCreateNode(A_COMPOUNDSTMT);
                                                                            $$->s1 = $3; // local declarations
                                                                            $$->s2 = $4; // statement list
                                                                            
                                                                            // print symbols defined at local level
                                                                            if (mydebug == 1)
                                                                                Display();
                                                                            
                                                                            // set offset and remove locally defined symbols from symbol table     
                                                                            
                                                                            if (offset > maxoffset) {
                                                                                maxoffset = offset;
                                                                            }
                                                                            
                                                                            offset -= Delete(level);
                                                                            level--; // decriment level for var declarations
                                                                            
                                                                        } // T_BEGIN local_declarations statement_list T_END
                    ;
        
// local variable declarations, next connected with eachother
local_declarations  : /* empty */                               {
                                                                    $$ = NULL;
                                                                }
                    | var_declaration local_declarations        {
                                                                    $$ = $1;
                                                                    $$->type = A_LOCALVARDEC;
                                                                    // local declarations next connnected
                                                                    $$->next = $2;
                                                                } // var_declaration local_declarations
                    ;
            
            
// statements, next connected with eachother
statement_list      : /*empty*/                     {
                                                        $$ = NULL;
                                                    }
                    | statement statement_list      {
                                                        $$ = $1;
                                                        $1->next = $2;
                                                    } // statement statement_list
                    ;


// different statements
statement           : expression_stmt       {
                                                $$ = $1;
                                            }
                    | compound_stmt         {
                                                $$ = $1;
                                            }
                    | selection_stmt        {
                                                $$ = $1;
                                            }
                    | iteration_stmt        {
                                                $$ = $1;
                                            }
                    | assignment_stmt       {
                                                $$ = $1;  
                                            }
                    | return_stmt           {
                                                $$ = $1;
                                            }
                    | read_stmt             {
                                                $$ = $1;
                                            }
                    | write_stmt            {
                                                $$ = $1;
                                            }
                    ;

// expression
expression_stmt     : expression ';'    {   $$ = ASTCreateNode(A_EXPRESSIONSTMT);
                                            $$->s1 = $1;
                                        }
                    | ';'               {$$ = ASTCreateNode(A_EXPRESSIONSTMT);}
                    ;
 
// selection, connected by multiple nodes if necessary
selection_stmt      : T_IF expression T_THEN statement                      {   // if then, then is linked to s1
                                                                                $$ = ASTCreateNode(A_IFTHENSTMT);
                                                                                $$->s1 = $2; // expression
                                                                                $$->s2 = ASTCreateNode(A_IFBODY);
                                                                                
                                                                                $$->s2->s1 = $4; // then statement
                                                                                $$->s2->s2 = NULL; // else statement
                                                                            } // T_IF expression T_THEN statement
                                                                            
                    | T_IF expression T_THEN statement T_ELSE statement     {   // if then else, if linked to s1, then linked to s2->s1, else linked to s2->s2
                                                                                $$ = ASTCreateNode(A_IFTHENSTMT);
                                                                                $$->s1 = $2; // expression
                                                                                
                                                                                // create a new node for the then and else statements
                                                                                $$->s2 = ASTCreateNode(A_IFBODY);
                                                                                
                                                                                $$->s2->s1 = $4; // then statement
                                                                                $$->s2->s2 = $6; // else statement
                                                                                
                                                                            } // T_IF T_THEN statement T_ELSE statement
                    ;
               
// iteration               
iteration_stmt      : T_WHILE expression T_DO statement     {   // links to expression with s1 and links to statement with s2
                                                                $$ = ASTCreateNode(A_ITERATIONSTMT);
                                                                $$->s1 = $2; // while expression
                                                                $$->s2 = $4; // do statement
                                                            } // T_WHILE expression T_DO statment
                    ;
               
// return              
return_stmt         : T_RETURN ';'                  {   // blank return
                                                        $$ = ASTCreateNode(A_RETURNSTMT);
                                                        
                                                    } // T_RETURN ;
                                                    
                    | T_RETURN expression ';'       {   // return with expression
                                                        $$ = ASTCreateNode(A_RETURNSTMT);
                                                        $$->s1 = $2; // return expression
                                                    } // T_RETURN expression ;
                    ;

// read
read_stmt           : T_READ var ';'    {
                                            $$ = ASTCreateNode(A_READSTMT);
                                            $$->s1 = $2;
                                        } // T_READ var ;
                    ;
   
// write
write_stmt          : T_WRITE expression ';'        {
                                                        $$ = ASTCreateNode(A_WRITESTMT);
                                                        $$->calculatedType = $2->calculatedType;
                                                        $$->s1 = $2;
                                                    } // T_WRITE expression ;
                                                
                                                
                    | T_WRITE T_QUOTED_STRING ';'   {
                                                        $$ = ASTCreateNode(A_WRITESTMT);
                                                        $$->label = $2;
                                                        $$->calculatedType = A_STRINGTYPE;
                                                        
                                                        // create temp symbol 
                                                        $$->name = CreateTemp();
                                                        
                                                        // TODO insert into symbol table?
                                                        
                                                        
                                                    } // T_WRITE T_QUOTED_STRING ;                            
                    ;

   
// variable assignments
assignment_stmt     : var '=' simple_expression ';'     {   // links to var with s1 and simple expression with s2

                                                            // type checking
                                                            // types do not match, barf
                                                            if ($1->calculatedType != $3->calculatedType) {
                                                                yyerror($1->name);
                                                                yyerror("Variable type and assignment type do not match");
                                                                exit(1);
                                                            }
                                                            
                                                            // types match, create AST node
                                                            $$ = ASTCreateNode(A_ASSIGNMENTSTMT);
                                                            $$->s1 = $1;
                                                            $$->s2 = $3;
                                                            $$->name = CreateTemp();
                                                            
                                                                                
                                                            // create temp symbol 
                                                            $$->symbol = Insert($$->name, $$->calculatedType, 0, level, 1, offset);
                                                            offset += 1;
                                                            
                                                        } // var = simple_expression ;
                    ;
       
// expressions
expression          : simple_expression     {$$ = $1;}
                    ;

// variable by itself, size is 1 for single variables
var                 : T_ID                      {   
                                                    struct SymbTab *p;
                                                    // if the symbol is found in the symbol table
                                                    if ((p=Search($1,level,1)) != NULL) {
                                                        // create AST node
                                                        $$ = ASTCreateNode(A_VAR);
                                                        $$->name = $1;
                                                        $$->size = 1;
                                                        
                                                        $$->symbol = p;
                                                        $$->calculatedType = p->Type;
                                                        
                                                        // if the symbol found in the symbol table is an array, barf
                                                        if (p->IsAFunc == 2) {
                                                            yyerror($1);
                                                            yyerror("Variable is an array, syntax error");
                                                            exit(1);
                                                        } // end array barf check
                                                        
                                                        // if the symbol found in the symbol table is a function, barf
                                                        if (p->IsAFunc == 1) {
                                                            yyerror($1);
                                                            yyerror("Assigned variable is a function, syntax error");
                                                            exit(1);
                                                        } // end function barf check
                                                        
                                                        
                                                    } // end if
                                                    // symbol is trying to be used without being in the symbol table, barf
                                                    else {
                                                        yyerror($1);
                                                        yyerror("Undeclared variable");
                                                        exit(1);
                                                    } // end else
                                                    
                                                } // T_ID
                                                
                                                
                                                
                    | T_ID '[' expression ']'   {
                                                    struct SymbTab *p;
                                                    // if the symbol is found in the symbol table
                                                    if ((p=Search($1,level,1)) != NULL) {
                                                        // create AST node
                                                        $$ = ASTCreateNode(A_VAR);
                                                        $$->name = $1;
                                                        $$->s1 = $3;
                                                        $$->size = -1; // size is set to -1 to flag as array
                                                        $$->symbol = p;
                                                        $$->calculatedType = p->Type;
                                                        
                                                        // symbol isn't an array, barf
                                                        if (p->IsAFunc == 0) {
                                                            yyerror($1);
                                                            yyerror("Variable isn't an array, syntax error");
                                                            exit(1);
                                                        } // end if
                                                        
                                                        // if the symbol found in the symbol table is a function, barf
                                                        if (p->IsAFunc == 1) {
                                                            yyerror($1);
                                                            yyerror("Assigned variable is a function, syntax error");
                                                            exit(1);
                                                        } // end function barf check
                                                        
                                                    } // end if
                                                    // symbol trying to be used without being in the symbol table, barf
                                                    else {
                                                        yyerror($1);
                                                        yyerror("Undeclared variable");
                                                        exit(1);
                                                    } // end else
                                                    
                                                    
                                                } // T_ID [ expression ]
                    ; 

// base for expressions
simple_expression   : additive_expression                                   {
                                                                                $$ = $1;
                                                                            }
                    | additive_expression relop additive_expression         {   // links to other simple expressions with s1 and addative expression with s2
                    
                                                                                // type checking, both sides of expression must be the same type
                                                                                // types do not match, barf
                                                                                if ($1->calculatedType != $3->calculatedType) {
                                                                                    yyerror("Type mismatch, both sides of expression must have the same type.");
                                                                                    exit(1);
                                                                                } // if
                                                                                
                                                                                // create AST node
                                                                                $$ = ASTCreateNode(A_EXPR);
                                                                                $$->s1 = $1;
                                                                                $$->operator = $2;
                                                                                $$->s2 = $3;
                                                                                $$->calculatedType = $1->calculatedType;
                                                                                $$->name = CreateTemp();
                                                                                
                                                                                
                                                                                // create temp symbol 
                                                                                $$->symbol = Insert($$->name, $$->calculatedType, 0, level, 1, offset);
                                                                                offset += 1;
                                                                                
                                                                            } // additive_expression relop additive_expression
                    ;
      
// regular expression operators
relop               : T_LESSEQUAL       {$$ = A_LESSEQUAL;}
                    | T_LESS            {$$ = A_LESS;}
                    | T_GREATER         {$$ = A_GREATER;}
                    | T_GREATEREQUAL    {$$ = A_GREATEREQUAL;}
                    | T_EQUAL           {$$ = A_EQUAL;}
                    | T_NOTEQUAL        {$$ = A_NOTEQUAL;}
                    ;
  
// additive expressions
additive_expression : term                              {
                                                            $$ = $1;
                                                        }
                                                        
                                                        
                    | additive_expression adop term     {   // links to other additive_expression with  s1 and term with s2
                    
                                                            // type checking, both sides of expression must be the same type
                                                            // types do not match, barf
                                                            if ($1->calculatedType != $3->calculatedType) {
                                                                yyerror("Type mismatch, both sides of expression must have the same type.");
                                                                exit(1);
                                                            } // if
                                                            
                                                            // types match, create AST node
                                                            $$ = ASTCreateNode(A_EXPR);
                                                            $$->s1 = $1;
                                                            $$->operator = $2;
                                                            $$->s2 = $3;
                                                            $$->calculatedType = $1->calculatedType;
                                                            $$->name = CreateTemp();
                                                            
                                                                                
                                                            // create temp symbol 
                                                            $$->symbol = Insert($$->name, $$->calculatedType, 0, level, 1, offset);
                                                            offset += 1;
                                                        } // additive_expression adop term
                    ;

// addition operators
adop                : '+'   {$$ = A_PLUS;}
                    | '-'   {$$ = A_MINUS;}
                    ;
     
// further expression base
term                : factor                    {$$ = $1;}


                    | term multop factor        {   // links to other terms with s1 and factor with s2
                    
                                                    // type checking, both sides of expression must be the same type
                                                    // types do not match, barf
                                                    if ($1->calculatedType != $3->calculatedType) {
                                                        yyerror("Type mismatch, both sides of expression must have the same type.");
                                                        exit(1);
                                                    } // if
                                                    
                                                    // types match, create AST node
                                                    $$ = ASTCreateNode(A_EXPR);
                                                    $$->s1 = $1;
                                                    $$->operator = $2;
                                                    $$->s2 = $3;
                                                    $$->calculatedType = $1->calculatedType;
                                                    $$->name = CreateTemp();
                                                    
                                                                                
                                                    // create temp symbol 
                                                    $$->symbol = Insert($$->name, $$->calculatedType, 0, level, 1, offset);
                                                    offset += 1;
                                                }
                    ;
     
// multiplication operators
multop              : '*'       {$$ = A_MULTIPLY;}
                    | '/'       {$$ = A_DIVIDE;}
                    | T_AND     {$$ = A_AND;}
                    | T_OR      {$$ = A_OR;}
                    ;
   
// factors
factor              : '(' expression ')'        {
                                                    $$ = $2;
                                                }
                                                
                                                
                    | T_NUM                     {   // size is the value of the num
                                                    $$ = ASTCreateNode(A_NUM);
                                                    $$->size = $1;
                                                    $$->calculatedType = A_INTTYPE;
                                                } // T_NUM
                                                
                                                
                    | var                       {   
                                                    $$ = $1;
                                                }
                                                
                                                
                    | call                      {
                                                    $$ = $1;
                                                }
                                                
                                                
                    | T_TRUE                    {   // int value of 1 in size
                                                    $$ = ASTCreateNode(A_NUM);
                                                    $$->size = 1;
                                                    $$->calculatedType = A_INTTYPE;
                                                    
                                                } // T_TRUE
                                                
                                                
                    | T_FALSE                   {   // int value of 0 in size
                                                    $$ = ASTCreateNode(A_NUM);
                                                    $$->size = 0;
                                                    $$->calculatedType = A_INTTYPE;
                                                    
                                                    
                                                } // T_FALSE
                                                
                                                
                    | T_NOT factor              {
                                                    $$ = $2;
                                                    $$->operator = A_NOT;
                                                    $$->name = CreateTemp();
                                                    
                                                                                
                                                    // create temp symbol 
                                                    $$->symbol = Insert($$->name, $$->calculatedType, 0, level, 1, offset);
                                                    offset += 1;
                                                } // T_NOT
                    ;
       
// calling a function, links to args with s1
call                : T_ID '(' args ')'     {
                                                struct SymbTab *p;
                                                
                                                // symbol is declared
                                                if ((p=Search($1,0,0)) != NULL) {
                                                
                                                    // symbol isn't a function, barf
                                                    if (p->IsAFunc != 1) {
                                                        yyerror($1);
                                                        yyerror("Undeclared function");
                                                        exit(1);
                                                    } // if
                                                    
                                                    
                                                    // arguments and parameter mismatch, barf
                                                    if (CompareFormals(p->fparms, $3) != 1 ) {
                                                        yyerror($1);
                                                        yyerror("Parameter arguments mismatch");
                                                        exit(1);
                                                    }
                                                    
                                                    
                                                    // create AST node
                                                    $$ = ASTCreateNode(A_CALL);
                                                    $$->name = $1;
                                                    $$->s1 = $3;
                                                    $$->calculatedType = p->Type;
                                                    $$->symbol = p;
                                                
                                                } // if
                                                
                                                // symbol isn't in symbol table
                                                else {
                                                    yyerror($1);
                                                    yyerror("Undeclared function");
                                                    exit(1);
                                                } // end else
                                                
                                            } // T_ID '(' args ')' 
                    ;
     
// args for functions
args                : arg_list      {$$ = $1;}
                    | /* empty */   {   
                                        
                                        $$ = ASTCreateNode(A_ARGS);
                                        $$->calculatedType = A_VOIDTYPE;
                                        
                                    } // empty
                    ;

// arg list for functions, links to expression with s1 and arg lists are next connected
arg_list            : expression                {
                                                    // create args ast node
                                                    $$ = ASTCreateNode(A_ARGS);
                                                    $$->s1 = $1;
                                                    $$->calculatedType = $1->calculatedType;
                                                    $$->name = CreateTemp();
                                                    
                                                                                
                                                    // create temp symbol 
                                                    $$->symbol = Insert($$->name, $$->calculatedType, 0, level, 1, offset);
                                                    offset += 1;
                                                    
                                                    
                                                } // expression
                                                
                    | expression ',' arg_list   {
                                                    // create args ast node
                                                    $$ = ASTCreateNode(A_ARGS);
                                                    $$->s1 = $1;
                                                    $$->next = $3;
                                                    $$->calculatedType = $1->calculatedType;
                                                    $$->name = CreateTemp();
                                                    
                                                                                
                                                    // create temp symbol 
                                                    $$->symbol = Insert($$->name, $$->calculatedType, 0, level, 1, offset);
                                                    offset += 1;
                                                    
                                                } // expression ',' arg_list
                    ;

                   
%%	/* end of rules, start of program */

int main(int argc, char * argv[]) { 

    // process the command line
    int i = 1;
    FILE *fp;
    char name[100];
    char * othername = "a.asm";
    int oFlag = 0;
    
    // read command line
    while (i < argc) {
        
        // debug flag given, turn on debug statements
        if ( strcmp(argv[i], "-d") == 0 ) 
            mydebug = 1;
        
        
        // file flag is given, set name for file
        if ( strcmp(argv[i], "-o") == 0 ) {
            
            // set file name
            strcpy(name, argv[i+1]);
            strcat(name, ".asm");
            oFlag = 1;
            
        }

        i++;
    }
    
    // parse the input
    yyparse();
    
    
    // file name given, set file name to given name
    if (oFlag) 
        fp = fopen(name,"w");
    // file name not given, set file name to a.asm
    else 
        fp = fopen(othername,"w");
    
    
    // check to make sure that file is made properly
    if (fp == NULL) {
        printf("ERROR, FILE CREATING ERROR\n");
        exit(1);
    }
    // write to asm file
    else {
        emit_data_segment(program, fp);
        emitAST(program, fp);
    }
    
    // print debug statements if debug flag is given
    if (mydebug == 1) {
        ASTprint(program, 0);
        printf("\nMain Symbol Table\n");
        Display();
    } // end debug statements
    
    
    
  
} // end main
