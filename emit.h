#ifndef _EMIT 
#define _EMIT

/*
Lab9 CS370 emit.h
Max Todd
4/26/21
Gives function declarations for creating MIPS code, defines constants for word size
*/


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ast.h"
#include "symtable.h"

#define WSIZE 4 // num of bytes in a word
#define LOGWSIZE 2 // num shifts to WSIZE


void emit (char * label, char * command, char * comment, FILE * fp);

void emit_data_segment (struct ASTnode * p, FILE *fp);
void emitAST (struct ASTnode * p, FILE *fp);
void emit_expression(struct ASTnode * p, FILE *fp);

void emit_global_variables (struct ASTnode * p, FILE *fp);
void emit_strings (struct ASTnode * p, FILE *fp);

void emit_function_head(struct ASTnode * p, FILE *fp);
void emit_function_tail(struct ASTnode * p, FILE *fp);

void emit_write_statement(struct ASTnode * p, FILE *fp);

void emit_read_statement(struct ASTnode * p, FILE *fp);

void emit_assignment_statement(struct ASTnode * p, FILE *fp);

void emit_return_statement(struct ASTnode * p, FILE *fp);

void emit_if_statement(struct ASTnode * p, FILE *fp);

void emit_while_statement(struct ASTnode * p, FILE *fp);


char * concatNumToString (char * str, int toAdd);
char * concatStrings (char * str, char * str2);

#endif
