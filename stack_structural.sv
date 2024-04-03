module stack_structural(
    inout wire[3:0] IO_DATA, 
    input wire RESET, 
    input wire CLK, 
    input wire[1:0] COMMAND, 
    input wire[2:0] INDEX
    );
    wire[2:0] INDm5;
    wire[3:0] ODATA;
    COUNT count(INDm5, COMMAND, CLK, RESET, INDEX);
    MEM5x4 mem(ODATA, IO_DATA, INDEX, COMMAND, RESET, CLK);
    and _signal(signal, COMMAND[1], CLK);
    not _n0(nsignal, signal);
    cmos cmos0(IO_DATA[0], ODATA[0], signal, nsignal);
    cmos cmos1(IO_DATA[1], ODATA[1], signal, nsignal);
    cmos cmos2(IO_DATA[2], ODATA[2], signal, nsignal);
    cmos cmos3(IO_DATA[3], ODATA[3], signal, nsignal);
endmodule

module COUNT(
    output wire[2:0] INDm5,
    input wire[1:0] COMMAND,
    input wire CLK, RESET,
    input wire[2:0] INDEX
    );
    not not_command0(nCOMMAND0, COMMAND[0]),
        not_command1(nCOMMAND1, COMMAND[1]);
    and _up(UP, COMMAND[0], nCOMMAND1, CLK),
        _down(DOWN, nCOMMAND0, COMMAND[1], CLK);
    wire[2:0] ind, shift; 
    POINTER ptr(ind, UP, DOWN, RESET);
    GET_SHIFT _shift(shift, COMMAND, INDEX);
    CALC_IND _out(INDm5, ind, shift);
endmodule

module POINTER(
    output wire[2:0] IND,
    input wire UP, DOWN, RESET
    );
    and _rend(rend, UP, redge),
        _lend(lend, DOWN, ledge),
        _up1(UP1, UP, Q0),
        _down1(DOWN1, DOWN, nQ0),
        _up2(UP2, UP1, Q1),
        _down2(DOWN2, DOWN1, nQ1),
        _redge(redge, nQ0, nQ1, nQ2),
        _ledge(ledge, nQ0, nQ1, nQ2);
    xor _clock(clock, UP, DOWN),
        _xor0(xor0, Q0, lend, rend, or0),
        _xor1(xor1, Q1, lend, or1),
        _xor2(xor2, Q2, rend, or2);
    or _or0(or0, UP, DOWN);
    or _or1(or1, UP1, DOWN1);
    or _or2(or2, UP2, DOWN2);
    TTRIGER _tr0(Q0, nQ0, xor0, reset, clock);
    TTRIGER _tr1(Q1, nQ1, xor1, reset, clock);
    TTRIGER _tr2(Q2, nQ2, xor2, reset, clock);
    assign IND = {xor2, xor1, xor0};
endmodule

module GET_SHIFT(
    output wire[2:0] SHIFT,
    input wire[1:0] COMMAND,
    input wire[2:0] INDEX
    );
    not not_command0(nCOMMAND0, COMMAND[0]),
        not_command1(nCOMMAND1, COMMAND[1]),
        _n0(n0, command0),
        _n1(n1, command1),
        _n2(n2, command2);
    and _command0(command0, nCOMMAND0, nCOMMAND1),
        _command1(command1, COMMAND[0], nCOMMAND1),
        _command2(command2, nCOMMAND0, COMMAND[1]),
        _command3(command3, COMMAND[0], COMMAND[1]),
        _out00(out00, command0, n0),
        _out01(out01, command0, n0),
        _out02(out02, command0, command0),
        _out10(out10, command1, n1),
        _out11(out11, command1, n1),
        _out12(out12, command1, command1),
        _out20(out20, command2, command2),
        _out21(out21, command2, n2),
        _out22(out22, command2, command2),
        _out30(out30, command3, INDEX[0]),
        _out31(out31, command3, INDEX[1]),
        _out32(out32, command3, INDEX[2]);
    or _bit0(SHIFT[0], out00, out10, out20, out30);
    or _bit1(SHIFT[1], out01, out11, out21, out31);
    or _bit2(SHIFT[2], out02, out12, out22, out32);
endmodule

module CALC_IND(
    output wire[2:0] INDm5,
    input wire[2:0] IND, SHIFT
    );
    wire[3:0] A1, A2, S, sum, dif;
    assign A1 = 4'b1001;
    assign A2 = {1'b0, IND};
    assign S = {1'b0, SHIFT};
    SUM4 _sum(sum, A1, A2);
    DIF4 _dif(dif, sum, S);
    MOD5 _mod5(INDm5, dif);
endmodule

module SUM4(
    output wire[3:0] S,
    input wire[3:0] A1, A2
    );
    SUM _sum0(S[0], c0, 1'b0, A1[0], A2[0]);
    SUM _sum1(S[1], c1, c0, A1[1], A2[1]);
    SUM _sum2(S[2], c2, c1, A1[2], A2[2]);
    SUM _sum3(S[3], c3, c2, A1[3], A2[3]);
endmodule

module SUM(
    output wire S, Cout,
    input wire Cin, A1, A2
    );
    xor _S(S, Cin, A1, A2);
    or _or0(or0, Cin, A1);
    or _or1(or1, Cin, A2);
    or _or2(or2, A1, A2);
    and _out(Cout, or0, or1, or2);
endmodule

module DIF4(
    output wire[3:0] D,
    input wire[3:0] A1, A2
    );
    DIF dif0(D[0], b0, 1'b0, A1[0], A2[0]);
    DIF dif1(D[1], b1, b0, A1[1], A2[1]);
    DIF dif2(D[2], b2, b1, A1[2], A2[2]);
    DIF dif3(D[3], b3, b2, A1[3], A2[3]);
endmodule

module DIF(
    output wire D, Bout,
    input wire Bin, A1, A2 
    );
    xor _D(D, Bin, A1, A2),
        _x1or2(x1or2, A1, A2);
    not _nx1or2(nx1or2, x1or2),
        _nA1(nA1, A1);
    and _and0(and0, Bin, nx1or2),
        _and1(and1, nA1, A2);
    or out(Bout, and0, and1);
endmodule

module MOD5(
    output wire[2:0] Am5,
    input wire[3:0] A
    );
    not _nA0(nA0, A[0]),
        _nA1(nA1, A[1]),
        _nA2(nA2, A[2]),
        _nA3(nA3, A[3]),
        _n0(n0, and0),
        _n1(n1, and1),
        _n2(n2, and2),
        _n3(n3, and3),
        _n4(n4, and4),
        _n5(n5, and5),
        _n6(n6, and6),
        _n7(n7, and7),
        _n8(n8, and8),
        _n9(n9, and9),
        _n10(n10, and10),
        _n11(n11, and11),
        _n12(n12, and12),
        _n13(n13, and13),
        _n14(n14, and14),
        _n15(n15, and15);
    wire[2:0] out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15;
    and _and0(and0, nA0, nA1, nA2, nA3),
        _and1(and1, A[0], nA1, nA2, nA3),
        _and2(and2, nA0, A[1], nA2, nA3),
        _and3(and3, A[0], A[1], nA2, nA3),
        _and4(and4, nA0, nA1, A[2], nA3),
        _and5(and5, A[0], nA1, A[2], nA3),
        _and6(and6, nA0, A[1], A[2], nA3),
        _and7(and7, A[0], A[1], A[2], nA3),
        _and8(and8, nA0, nA1, nA2, A[3]),
        _and9(and9, A[0], nA1, nA2, A[3]),
        _and10(and10, nA0, A[1], nA2, A[3]),
        _and11(and11, A[0], A[1], nA2, A[3]),
        _and12(and12, nA0, nA1, A[2], A[3]),
        _and13(and13, A[0], nA1, A[2], A[3]),
        _and14(and14, nA0, A[1], A[2], A[3]),
        _and15(and15, A[0], A[1], A[2], A[3]),
        _out00(out0[0], n0, and0),
        _out01(out0[1], n0, and0),
        _out02(out0[2], n0, and0),
        _out10(out1[0], and1, and1),
        _out11(out1[1], n1, and1),
        _out12(out1[2], n1, and1),
        _out20(out2[0], n2, and2),
        _out21(out2[1], and2, and2),
        _out22(out2[2], n2, and2),
        _out30(out3[0], and3, and3),
        _out31(out3[1], and3, and3),
        _out32(out3[2], n3, and3),
        _out40(out4[0], n4, and4),
        _out41(out4[1], n4, and4),
        _out42(out4[2], and4, and4),
        _out50(out5[0], n5, and5),
        _out51(out5[1], n5, and5),
        _out52(out5[2], n5, and5),
        _out60(out6[0], and6, and6),
        _out61(out6[1], n6, and6),
        _out62(out6[2], n6, and6),
        _out70(out7[0], n7, and7),
        _out71(out7[1], and7, and7),
        _out72(out7[2], n7, and7),
        _out80(out8[0], and8, and8),
        _out81(out8[1], and8, and8),
        _out82(out8[2], n8, and8),
        _out90(out9[0], n9, and9),
        _out91(out9[1], n9, and9),
        _out92(out9[2], and9, and9),
        _out100(out10[0], n10, and10),
        _out101(out10[1], n10, and10),
        _out102(out10[2], n10, and10),
        _out110(out11[0], and11, and11),
        _out111(out11[1], n11, and11),
        _out112(out11[2], n11, and11),
        _out120(out12[0], n12, and12),
        _out121(out12[1], and12, and12),
        _out122(out12[2], n12, and12),
        _out130(out13[0], and13, and13),
        _out131(out13[1], and13, and13),
        _out132(out13[2], n13, and13),
        _out140(out14[0], n14, and14),
        _out141(out14[1], n14, and14),
        _out142(out14[2], and14, and14),
        _out150(out15[0], n15, and15),
        _out151(out15[1], n15, and15),
        _out152(out15[2], n15, and15);
    or or0(Am5[0], out0[0], out1[0], out2[0], out3[0], out4[0], out5[0], out6[0], out7[0], out8[0], out9[0], out10[0], out11[0], out12[0], out13[0], out14[0], out15[0]);
    or or1(Am5[1], out0[1], out1[1], out2[1], out3[1], out4[1], out5[1], out6[1], out7[1], out8[1], out9[1], out10[1], out11[1], out12[1], out13[1], out14[1], out15[1]);
    or or2(Am5[2], out0[2], out1[2], out2[2], out3[2], out4[2], out5[2], out6[2], out7[2], out8[2], out9[2], out10[2], out11[2], out12[2], out13[2], out14[2], out15[2]);
endmodule

module MEM5x4(
    output wire[3:0] ODATA,
    input wire[3:0] IDATA,
    input wire[2:0] INDEX,
    input wire[1:0] COMMAND,
    input wire RESET, CLK
    );
    THREE_TO_FIVE ttf(M0, M1, M2, M3, M4, INDEX);
    not not_command1(nCOMMAND1, COMMAND[1]);
    and _write(write, COMMAND[0], n_COMMAND1),
        _clock0(clock0, M0, CLK),
        _clock1(clock1, M1, CLK),
        _clock2(clock2, M2, CLK),
        _clock3(clock3, M3, CLK),
        _clock4(clock4, M4, CLK);
    wire[3:0] ODATA0, ODATA1, ODATA2, ODATA3, ODATA4;
    MEM4 mem0(ODATA0, IDATA, RESET, write, clock0);
    MEM4 mem1(ODATA1, IDATA, RESET, write, clock1);
    MEM4 mem2(ODATA2, IDATA, RESET, write, clock2);
    MEM4 mem3(ODATA3, IDATA, RESET, write, clock3);
    MEM4 mem4(ODATA4, IDATA, RESET, write, clock4);
    or or0(ODATA[0], ODATA0[0], ODATA1[0], ODATA2[0], ODATA3[0], ODATA4[0]);
    or or1(ODATA[1], ODATA0[1], ODATA1[1], ODATA2[1], ODATA3[1], ODATA4[1]);
    or or2(ODATA[2], ODATA0[2], ODATA1[2], ODATA2[2], ODATA3[2], ODATA4[2]);
    or or3(ODATA[3], ODATA0[3], ODATA1[3], ODATA2[3], ODATA3[3], ODATA4[3]);
endmodule

module MEM4(
    output wire[3:0] ODATA,
    input wire[3:0] IDATA,
    input wire RESET, W, CLK
    );
    not reset(nRESET, RESET),
        _reset0(reset0, set0),
        _reset1(reset1, set1),
        _reset2(reset2, set2),
        _reset3(reset3, set3);
    and _write(write, W, CLK),
        _set0(set0, IDATA[0], nRESET),
        _set1(set1, IDATA[1], nRESET),
        _set2(set2, IDATA[2], nRESET),
        _set3(set3, IDATA[3], nRESET),
        _out0(ODATA[0], Q0, CLK),
        _out1(ODATA[1], Q1, CLK),
        _out2(ODATA[2], Q2, CLK),
        _out3(ODATA[3], Q3, CLK);
    or _clock(clock, RESET, write);
    RSTRIGER tr0(Q0, nQ0, reset0, set0, clock);
    RSTRIGER tr1(Q1, nQ1, reset1, set1, clock);
    RSTRIGER tr2(Q2, nQ2, reset2, set2, clock);
    RSTRIGER tr3(Q3, nQ3, reset3, set3, clock);
endmodule

module THREE_TO_FIVE(
    output wire M0, M1, M2, M3, M4,
    input wire[2:0] INDEX
    );
    not _n0(n0, INDEX[0]),
        _n1(n1, INDEX[1]),
        _n2(n2, INDEX[2]);
    and _M0(M0, n0, n1, n2),
        _M1(M1, INDEX[0], n1, n2),
        _M2(M2, n0, INDEX[1], n2),
        _M3(M3, INDEX[0], INDEX[1], n2),
        _M4(M4, n0, n1, INDEX[2]);
endmodule

module TTRIGER(
    output wire Q, nQ,
    input wire D, R, CLK
    );
    not not_D(nD, D),
        not_R(nR, R),
        not_CLOCK(n_clock, clock);
    or _reset(reset, nD, R),
        _clock(clock, R, CLK);
    and _set(set, D, nR);
    RSTRIGER tr1(tr1_Q, tr1_nQ, reset, set, clock);
    RSTRIGER tr2(Q, nQ, tr1_nQ, tr1_Q, n_clock);
endmodule

module RSTRIGER(
    output wire Q, nQ,
    input wire R, S, CLK
    );
    and and_R(w_and_R, R, CLK),
        and_S(w_and_S, S, CLK);
    nor nor_RESULT(Q, w_and_R, nQ),
        nor_nRESULT(nQ, w_and_S, Q);
endmodule