# Algol C Compiler



## How it works
The compiler works through the following steps:
1. **Lex**

   Lex is a tokenizer. A file is inputted, and lex returns the tokens defined in the file, and sends it to yacc, which is the next step.
    Tokens are what the programming language is going to recognize as correct syntax. For example here are token translations: 
    int  ->  T_INT
    of   ->  T_OF
    read ->  T_READ

2. **Yacc**
   
    Yacc recieves the tokens that lex sends, and defines valid statements with the given tokens. 


3. **ast**
   
    One of the main jobs yacc does is create an abstract syntax tree, with the help of ast.c. The abstract syntax tree is then used
    in the next step:

4. **emit**
   
    Emit uses the abstract syntax tree to create MIPS assembly code which can then be ran.
