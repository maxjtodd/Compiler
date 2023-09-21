/*
Lab9 CS370 emit.c
Max Todd
4/26/21
Gives function definitions for creating MIPS code depending on recieved ASTnode type


a)  Can only read and write variables and  write numbers and write strings 40% off.
b)  Read/Write and Assignment are fully functional with scalars  30% off
c)  Can do a-b and "if" and "while"  20% off
d)  Can do a-c and also arrays   10%
e)  Can do a-d and handle function calls


Out of the following grading criteria, I would like to be graded at D.

*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "emit.h"
#include "ast.h"
#include "symtable.h"


// PRE: strings for printing a label, command, and comment for MIPS code entry, and a file pointer to print them to
// POST: properly indented MIPS code in file fp
void emit (char * label, char * command, char * comment, FILE * fp) {
    
    // label is empty
    if (strcmp(label,"") == 0) {
        
        // comment is empty
        if (strcmp(comment,"") != 0) 
            fprintf(fp, "\t\t%s\t#%s\n", command, comment);
        
        // comment isn't empty
        else 
            fprintf(fp, "\t\t%s\n", command);
        
    } // if
    
    // label isn't empty
    else 
        fprintf(fp, "%s:\t\t%s\t#%s\n", label, command, comment);
    
    
} // end emit





// PRE: ASTnode begining of program, and file FP to print MIPS code to. Called by YACC file.
// POST: MIPS code, entering the data segment with all global variables and strings
void emit_data_segment(struct ASTnode * p, FILE *fp) {
    
    // print data segment into file
    fprintf(fp, ".data # start of the data section, strings first\n");
    
    // string segment 
    fprintf(fp, "\n");
    fprintf(fp, "_NL:\t\t.asciiz \"\\n\" # NEW LINE\n");
    
    // add strings
    emit_strings(p, fp);
    
    fprintf(fp, "\n");
    
    
    // global variable segment
    fprintf(fp, ".align 2 # start all global variable aligned\n");
    
    // add global variables
    emit_global_variables(p, fp);
    
    fprintf(fp, "\n\n");
    
    // print text label
    fprintf(fp, ".text\n\n");
    
    // declare main as global
    fprintf(fp, ".globl main\n\n\n");
    
    
} // end emit_data_segment





// PRE: ASTnode, begining of the program, and file fp to print MIPS code to. Called by emit_data_segment.
// POST: MIPS code, adding all the global variables into the data segment. 
void emit_global_variables (struct ASTnode * p, FILE *fp) {
    
    // base case, leave line
    if ( p == NULL )
        return;
    
    // if the node is a vardec and is global, emit to file
    if (p->type == A_VARDEC && p->symbol->level == 0) {
        
        int sizeNum = p->size * 4;        
        char * space = concatNumToString(".space ", sizeNum);
        emit(p->name, space, "define global variable", fp);
        
    }
    
    // search for other global variables to emit
    emit_global_variables(p->s1, fp);
    emit_global_variables(p->next, fp);
    emit_global_variables(p->s2, fp);
    
    
} // emit_global_variables





// PRE: ASTnode, begining of the program, and file fp to print MIPS code to. Called by emit_data_segment.
// POST: MIPS code, adding all the strings into the data segment.
void emit_strings (struct ASTnode * p, FILE *fp) {
    
    // base case, leave line
    if ( p == NULL )
        return;
    
    // if the node has a string, emit to file
    if (p->calculatedType == A_STRINGTYPE) {
                        
        char * command = concatStrings(".asciiz ", p->label);
        emit(p->name, command, "define global string", fp);
        
    } // if
    
    // search for other strings to emit
    emit_strings(p->s1, fp);
    emit_strings(p->next, fp);
    emit_strings(p->s2, fp);
    
} // emit_strings






// PRE: ASTnode, beginning of the program. File fp to print MIPS code to. Called by YACC file.
// POST: MIPS code, adding all the MIPS code in the text segment to file fp
void emitAST (struct ASTnode * p, FILE *fp) {
    
    // check for null ast node
    if (p == NULL)
        return;
    
    // Node cannot be null at this point
    switch (p->type) {
        
        // variable declaration
        case A_VARDEC:
            
            // VARDEC's taken care of, by emit_global_variables and leaving space in the activation record for local variables. Move on.
            emitAST(p->next, fp);
            break;
            
            
        // function declaration 
        case A_FUNDEC:
            
            // emit the function head
            emit_function_head(p, fp);
            
            // emit all the statements inside the function
            emitAST(p->s2, fp); // compound statement
            
            // emit the function tail
            emit_function_tail(p, fp);
            
            emitAST(p->next, fp); // emit further function declarations
            
            break;
            
 
        // compound statements, for multiple statements
        case A_COMPOUNDSTMT:
            
            // local var decs are taken care of by activation record
            
            // emit the statements in the compound statement
            emitAST(p->s2, fp);
            
            
            emitAST(p->next, fp);
            break;
            
            
        // write statement
        case A_WRITESTMT:
            
            // emit the write statement with helper function
            emit_write_statement(p, fp);
            
            emitAST(p->next, fp); // emit further statements
            break;
            
        
        // read statement
        case A_READSTMT:
            
            // emit the read statement with helper function
            emit_read_statement(p, fp);
            
            emitAST(p->next, fp); // emit further statements
            break;
            
        
        // assignment statement
        case A_ASSIGNMENTSTMT:
            
            // emit the assignment statement with helper function
            emit_assignment_statement(p, fp);
            
            emitAST(p->next, fp); // emit further statements
            break;
            
            
        // expression statement
        case A_EXPRESSIONSTMT:
            
            // evaluate expression if the statement isn't empty
            if (p->s1 != NULL)
                // emit the expression with helper function emit_expression
                emit_expression(p->s1, fp);
            
            emitAST(p->next, fp); // emit further statements
            break;
        
        
        // return statement
        case A_RETURNSTMT:
            
            // emit the return statement with helper function
            emit_return_statement(p, fp);
            
            emitAST(p->next, fp); // emit further statements
            break;
        
            
        // if then OR if then else statement
        case A_IFTHENSTMT:
            
            // emit the if then or if then else statement with helper function
            emit_if_statement(p, fp);
            
            emitAST(p->next, fp); // emit further statements
            break;
            
        case A_IFBODY:
            break;
        
            
        // while statement
        case A_ITERATIONSTMT:
            
            // emit while statement with helper function
            emit_while_statement(p, fp);
            
            emitAST(p->next, fp); // emit further statements
            break;
            
        
        // barf handling
        default:
            printf("Shouldn't Be here! Unkown node type emitAST\n");
            exit(1);
        
        
    } // switch
    
    
} // emitAST





// PRE: astnode p as a identifier
// POST: mips code loading the value of the location ijn $a0
void emit_identifier(struct ASTnode * p, FILE *fp) {
    
    char s[100];
    
    // variable is an array, get index accessor and store in t0
    if (p->s1 != NULL) {
        
        // get index information stored in $a0
        emit_expression(p->s1,fp);
        
        sprintf(s,"sll $t0, $a0, %d", LOGWSIZE);
        emit("",s,"multiply wordsize",fp);
        
    } // if
    
    
    // global variable
    if (p->symbol->level == 0) {
        sprintf(s, "la $a0, %s", p->name);
        emit("", s, "Load global variable from memory, expression", fp);
    } // if
    
    // local variable
    else {
        sprintf(s, "li $a0 %d", p->symbol->offset * WSIZE);
        emit("", s, "get identifier offset", fp);
        emit("", "add $a0,$a0,$sp", "we have direct reference to memory", fp);
    } // else
    
    
    // variable is an array, add index to address
    if (p->s1 != NULL) 
        emit("","add $a0, $a0, $t0", "increase address by t0 to get array access point", fp);
        
} // emit_identifier





// PRE: astnode p as an expression
// POST: mips code handling the expression, evaluating it all and leaving result in $a0
void emit_expression(struct ASTnode * p, FILE *fp) {
    
    char s[100];
    
    // base case, lowest possible evaluations of expression
    // store value into $a0
    switch (p->type) {
        
        // number
        case A_NUM:
            sprintf(s, "li $a0 %d", p->size);
            emit("", s, "Load a number, expression", fp);
            return;
            break;
        
        // variable
        case A_VAR:
            
            // emit the identifier with emit_identifier
            emit_identifier(p, fp); // gets address of var
            
            // turn address into value
            emit("", "lw $a0 ($a0)", "expression is identifier", fp);
            
            return;
            break;
            
        case A_CALL:
            return;
            break;
            
            
        default:
            break;
        
    }
    
    
    // recursive case
    
    // evaluate left side of expression
    emit_expression(p->s1, fp);
    
    // store the left hand side of expression into space dedicated to expression
    sprintf(s,"sw $a0 %d($sp)", p->symbol->offset * WSIZE);
    emit("",s,"store a0 termporarily",fp);

    // evaluate right side of expression
    emit_expression(p->s2, fp);
    
    // move right side evaluation to $t0
    emit("","move $t0 $a0","store right hand side evaluation in $t0",fp);
    
    // get the left hand side back in $a0
    sprintf(s,"lw $a0 %d($sp)", p->symbol->offset * WSIZE);
    emit("",s,"load left hand side",fp);
    
    
    // handle any math being done
    switch (p->operator) {
        
        
        // +
        case A_PLUS: 
            emit("","add $a0,$a0,$t0","complete add expression",fp);
            break;
        
            
        // -
        case A_MINUS:
            emit("","sub $a0,$a0,$t0","complete subtract expression",fp);
            break;
        
            
        // *
        case A_MULTIPLY:
            emit("","mul $a0,$a0,$t0","complete multiplication expression",fp);
            break;
        
        
        // /
        case A_DIVIDE:
            emit("","div $a0,$t0","divide the two halfs of the expression",fp);
            emit("","mflo $a0","move the quotient to a0, complete division expression",fp);
            break;
           
            
        // and
        case A_AND:
            emit("","and $a0,$a0,$t0","complete and expression",fp);
            break;
        
            
        // or
        case A_OR:
            emit("","or $a0,$a0,$t0","complete or expression",fp);
            break;
        
            
        // <=
        case A_LESSEQUAL: 
            emit("","add $t0, $t0, 1", "EXPR LE add one to do compare",fp);
            emit("","slt $a0, $a0, $t0","end expression less than equal to", fp);
            break;
        
            
        // <
        case A_LESS:
            emit("","slt $a0, $a0, $t0","end expression less than", fp);
            break;
            
        
            
        // >
        case A_GREATER:
            emit("","sgt $a0, $a0, $t0","end expression greater than", fp);
            break;
            
        
            
        // >=
        case A_GREATEREQUAL:
            emit("","add $a0, $a0, 1", "EXPR GRE add one to do compare",fp);
            emit("","slt $a0, $t0, $a0","end expression greater than equal to",fp);
            break;
        
            
        // ==
        case A_EQUAL:
            emit("","seq $a0, $a0, $t0", "end expression equal to", fp);
            break;
            
            
        // !=
        case A_NOTEQUAL:
            emit("","sne $a0, $a0, $t0", "end expression not equal to", fp);
            break;
            
        // ! expression
        case A_NOT:
            
            emit("","not $t0, $a0","Ones compliment", fp); 
            emit("","add $t0, $t0 1","if we were 0 we are now 0", fp); 
            emit("","srl $t0, $t0 31","extract sign bit", fp); 
            emit("","srl $t0, $t0 31","extract sign bit of neg", fp); 
            emit("","or $a0, $a0 $t0","result 0 if was 0 otherwise a 1", fp); 
            emit("","xor $a0, $a0 1","flips the bit to get not", fp); 
            
            break;
        
        default:
            break;
        
    } // switch
    
    
} // emit_expression





// PRE: ptr to FUNDEC
// POST: MIPS code in fp to handle the activation record carve out
void emit_function_head(struct ASTnode * p, FILE *fp) {
    
    // print function label
    emit(p->name, "", "Start of function", fp);
    
    char* newSP = concatNumToString("subu $t0  $sp ", (p->symbol->mysize) * WSIZE);
    
    emit("", newSP, "set up $t0 to be the new spot for SP", fp);
    emit("", "sw $ra ($t0)", "Store the return address", fp);
    emit("", "sw $sp 4($t0)", "Store the old stack pointer", fp);
    emit("", "move $sp $t0", "Set the stack pointer to the new value", fp);
    
    fprintf(fp, "\n");
} // emit_function_head





// PRE: ptr to FUNDEC
// POST: MIPS code in fp to handle function exit
void emit_function_tail(struct ASTnode * p, FILE *fp) {
    
    emit("","li $v0 0","return NULL (0)",fp);
    emit("","lw $ra ($sp)", "reset return address", fp);
    emit("", "lw $sp 4($sp)", "reset stack pointer", fp);
    
    fprintf(fp, "\n");

    // function is main
    if (strcmp("main", p->name) == 0) {
        emit("", "li $v0, 10", "Main function ends", fp);
        emit("", "syscall", " MAIN FUNCTION EXITS", fp);
    } // if
    
    // function isn't main
    else 
        emit("", "jr $ra", "function end", fp);
    
    
} // emit_function_tail





// PRE: ptr to write_statement 
// POST: MIPS code in fp to handle write statements
void emit_write_statement(struct ASTnode * p, FILE *fp) {
    
    
    // Printing a string
    if (p->calculatedType == A_STRINGTYPE) {
        
        // fetch and print string from memeory
        emit("", "li $v0, 4", "print a string", fp);
        char * fetchLocation = concatStrings("la $a0, ", p->name);
        emit("", fetchLocation, "print fetch string location", fp);
        emit("", "syscall", "", fp);
        
    } // if
    
    
    // Printing an expression 
    else {
        
        // evaluate expression
        emit_expression(p->s1, fp);
    
        // print expression value
        emit("", "li $v0 1", "Print global variable", fp);
        emit("", "syscall", "", fp);
        
    } // else
    
    fprintf(fp, "\n");
    
} // emit_write_statement





// PRE: ptr to read_statement 
// POST: MIPS code in fp to handle read statements
void emit_read_statement(struct ASTnode * p, FILE *fp) {
    
    
    char s[100];
    

    // emit the identifier being read into
    emit_identifier(p->s1, fp);
    
    // read in number and save to $a0
    emit("", "li $v0, 5", "Read in a number", fp);
    emit("", "syscall", "", fp);
    emit("", "sw $v0 ($a0)", "End read statement", fp);
    
    fprintf(fp, "\n");
    
} // emit_read_statement





// PRE: ptr to assignment statement ast node
// POST: MIPS code in fp to handle assignment
void emit_assignment_statement(struct ASTnode * p, FILE *fp) {
    
    char s[100];
    
    emit_expression(p->s2, fp); // evaluate expression, gets stored in a0

    // need to use temp space used for assignment
    sprintf(s, "sw $a0, %d($sp)", (p->symbol->offset * WSIZE));
    emit("",s,"store assignment value in memory",fp);
    
    // get var
    emit_identifier(p->s1, fp);
    sprintf(s,"lw $a1, %d($sp)", (p->symbol->offset * WSIZE));
    emit("",s,"Get right hand side stored value",fp);
    
    emit("","sw $a1 ($a0)","Assigned, end assignment statement",fp);
    

    fprintf(fp,"\n");
    
} // emit_assignment_statement





// PRE: ptr to return statement ast node
// POST: MIPS code in fp to handle return statement
void emit_return_statement(struct ASTnode * p, FILE *fp) {
    
    // empty return statement, return 0
    if (p->s1 == NULL) 
        emit("","li $v0 0", "return NULL zero (0)",fp);
    
    // non empty return statement, set up a0 with return information
    else
        emit_expression(p->s1, fp);
    
    emit("","lw $ra ($sp)", "reset return address", fp);
    emit("","lw $sp 4($sp)", "reset stack pointer", fp);
    
    /*
	li $v0, 10		#Main function ends 
	syscall		#MAIN FUNCTION EXITS
    */
    
    
} // emit_return_statement





// PRE: ptr to if then statement ast node
// POST: MIPS code in fp to handle return statement
void emit_if_statement(struct ASTnode * p, FILE *fp) {
    
    char s[100];
    
    // create labels for the different branches
    char * elseLabel = CreateTemp();
    char * ifStatementDoneLabel = CreateTemp();
    
    // emit the expression being evaluated by the if statement
    emit_expression(p->s1, fp);
    
    // create jump commands to jump if if statement doesn't evaluate to true
    sprintf(s, "beq $a0 $0 %s", elseLabel);
    emit("",s,"jump to else, start of if statement",fp);
    fprintf(fp,"\n");
    
    // emit the then portion of the statement
    emitAST(p->s2->s1, fp); 
        
    fprintf(fp, "\n");
        
    // print jump command
    sprintf(s, "j %s", ifStatementDoneLabel);
    emit("", s, "then statement end", fp);
    fprintf(fp, "\n");
        
    // print else label
    emit(elseLabel,"","else target",fp);
        
    fprintf(fp,"\n");
    
    // emit the else portion of the statement
    if (p->s2 != NULL)
        emitAST(p->s2->s2, fp); 
        
    fprintf(fp,"\n");
        
    // print end if label
    emit(ifStatementDoneLabel, "", "end of if statement", fp);
    
} // emit_if_statement





// PRE: ptr to while statement ast node
// POST: MIPS code in fp to handle while statement
void emit_while_statement(struct ASTnode * p, FILE *fp) {
    
    
    char s[100];
    
    // create labels 
    char * whileBegin = CreateTemp();
    char * whileEnd = CreateTemp();
    
    // print while loop back label
    emit(whileBegin,"","WHILE top argument", fp);
    
    // get the expression 
    emit_expression(p->s1, fp);
    
    // handle loop end
    sprintf(s,"beq $a0 $0 %s", whileEnd);
    emit("",s, "WHILE branch out", fp);
    
    fprintf(fp,"\n");
    
    // handle statements in while
    emitAST(p->s2, fp);
    
    fprintf(fp,"\n");
    
    // handle jumping back
    sprintf(s, "j %s", whileBegin);
    emit("",s,"WHILE jump back", fp);
    
    // print exit label
    fprintf(fp,"\n");
    emit(whileEnd, "", "WHILE end", fp);
    
    fprintf(fp,"\n");
} // emit_while_statement


// PRE: ptr to string and int to be concatted
// POST: char *, containing string and number
char * concatNumToString (char * str, int toAdd) {
        
    // get the num into string form
    int len = snprintf(NULL, 0, "%d", toAdd);
    char* numStr = malloc (len + 1);
    snprintf(numStr, len + 1, "%d", toAdd);
    
    // allocate enough space for return string
    char * returnString = (char *) malloc (1 + strlen(str) + strlen(numStr) );
    
    // get all string information inside return string
    strcpy(returnString, str);
    strcat(returnString, numStr);
    
    // return return string
    return returnString;
    
} // concatNumToString


// PRE: ptr to string and ptr to string2 to be concatted
// POST: ptr to string containing contents of string and string2
char * concatStrings (char * str, char * str2) {
    
    char * returnString = (char *) malloc (1 + strlen(str) + strlen(str2));
    strcpy(returnString, str);
    strcat(returnString, str2);
    
    return returnString;
    
    
} // concatStrings
