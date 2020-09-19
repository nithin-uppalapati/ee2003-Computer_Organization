.global fib
fib:
    # li a0, 1    # Return result in reg a0
    li a3, 1    # is control signal
    li a4, 1
    add a5, a0, x0   ## try implementing recursion by calling fib.s again from fib.s ....is this possible...?
    li a0, 0
    li a1, 1 

    LOOP: 
    addi a3, a3, 1
    add a4, a1, a0
    add a0, x0, a1
    add a1, x0, a4
    
    BNE a3, a5, LOOP

    add a0, x0, a4

    jr ra       # Return address was stored by original call . 
    # addi a7,x0,93
    # ecall
