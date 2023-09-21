/*
Lab9 CS370 lab9.l
Max Todd
4/26/21
Defines algol c tokens, outputs tokens to yacc
*/


%{

// debug flag
int mydebug=0;
// linecount tracker
int linecount = 1;

#include "ast.h"
#include "y.tab.h"



%}


%%

int                 { return(T_INT); }
void                { return(T_VOID); }
boolean             { return(T_BOOLEAN); }
begin               { return(T_BEGIN); }
end                 { return(T_END); }
of                  { return(T_OF); }
read                { return(T_READ); }
return              { return(T_RETURN); }
write               { return(T_WRITE); }
if                  { return(T_IF); }
then                { return(T_THEN); }
else                { return(T_ELSE); }
while               { return(T_WHILE); }
do                  { return(T_DO); }
true                { return(T_TRUE); }
false               { return(T_FALSE); }
not                 { return(T_NOT); }
and                 { return(T_AND); }
or                  { return(T_OR); }
\<\=                { return(T_LESSEQUAL); }
\<                  { return(T_LESS); }
\>                  { return(T_GREATER); }
\>\=                { return(T_GREATEREQUAL); }
\=\=                { return(T_EQUAL); }
\!\=                { return(T_NOTEQUAL); }


\".*\"	{if (mydebug) fprintf(stderr,"Quoted String found\n");  // return variable token for valid variable names with a char* name of the variable
                            yylval.string = strdup(yytext); return(T_QUOTED_STRING);}

                            
[a-zA-Z][a-zA-Z0-9_]*	{if (mydebug) fprintf(stderr,"ID found\n");  // return variable token for valid variable names with a char* name of the variable
                            yylval.string = strdup(yytext); return(T_ID);}
                            
                            
(-)?[0-9][0-9]*	          {if (mydebug) fprintf(stderr,"Digit found\n");   // return integer token for numbers and digits with a int of the value of the number
                       yylval.value = atoi((const char *)yytext); return(T_NUM);}
                       
                       
[ \t]		          { /* do nothing */ } // whitespace / tab

[,;[\]()\-+*/=] 	  { return (*yytext);} // single characters

\/\/.*                { /*do nothing*/ } // comments
                       
\n 		              { linecount++; } // newlines
                       

%%



int yywrap(void)
{ return 1;}


