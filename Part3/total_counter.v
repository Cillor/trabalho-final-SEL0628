`timescale 1 ns/100 ps  //Tirar no DigitalJS

// Contador completo com os 3 contadores, registradores e display [bcd -> 7 segmentos]
module total_counter( output a0, b0, c0, d0, e0, f0, g0,    // Display unidades
                      output a1, b1, c1, d1, e1, f1, g1,    // Display dezenas
                      output a2, b2, c2, d2, e2, f2, g2,    // Display centenas
                      output enb_machine,   // Saída que ativa a máquina de estados
                      input enable,	// Ativar a contagem
                      input rst,	// Reset
                      input ld,		// Load
                      input clk);	// Clock
  
    wire enb_1, enb_2, enb_3, enb_4;
  	counter_block block0(a0, b0, c0, d0, e0, f0, g0, enb_1, enable, rst, clk, ld);	// Contador das unidades
  	counter_block block1(a1, b1, c1, d1, e1, f1, g1, enb_2, enb_1, rst, clk, ld);	// Contador das dezenas
    and(enb_3, enb_2, enb_1);
  	counter_block block2(a2, b2, c2, d2, e2, f2, g2, enb_4, enb_3, rst, clk, ld);	// Contador das centenas
    and(enb_machine, enb_4, enb_3);

endmodule

// Módulo do registrador
module reg_4bit (output [3:0] q, //	Saída para o display [bcd -> 7 segmentos]
                 input ld,	// Load
                 input clk,	// Clock
                 input [3:0] d);	// Entrada do valor que estava no contador
  	always @(posedge clk) begin
		if (ld) begin	// Se load estiver ativado
      		q = d;
    	end // Caso contrario continua do jeito que está
  	end

endmodule

// Módulo do display [bcd -> 7 segmentos]
module bcd27seg (output a, b, c, d, e, f, g, input [3:0] BCD);//BCD[3], BCD[2], BCD[1], BCD[0]

    wire nB2nB0, B2B0, nB1nB0, B1B0, nB2B1, B1nB0, B2nB1, B2nB0, B2nB1B0;
    wire [3:0] nBCD; //nBCD[3], nBCD[2], nBCD[1], nBCD[0]
    not (nBCD, BCD);
    and (B2nB1B0, BCD[2], nBCD[1], BCD[0]);
    and (nB2nB0, nBCD[2], nBCD[0]);
    and (nB1nB0, nBCD[1], nBCD[0]);
    and (nB2B1, nBCD[2], BCD[1]);
    and (B2nB1, BCD[2], nBCD[1]);
    and (B2nB0, BCD[2], nBCD[0]);
    and (B1nB0, BCD[1], nBCD[0]);
    and (B2B0, BCD[2], BCD[0]);
    and (B1B0, BCD[1], BCD[0]);

    or (a, BCD[3], BCD[1], nB2nB0, B2B0);
    or (b, nBCD[2], nB1nB0 , B1B0);
    or (c, BCD[2], nBCD[1], BCD[0]);
    or (d, BCD[3], nB2nB0 , nB2B1 , B1nB0, B2nB1B0);
    or (e, nB2nB0 , B1nB0);
    or (f, BCD[3], nB1nB0 , B2nB1, B2nB0);
    or (g, BCD[3], B1nB0 , nB2B1 , B2nB1);

endmodule

// Módulo para cada um dos blocos com contador, registrador e display [bcd -> 7 segmentos]
module counter_block( output a, b, c, d, e, f, g,	// Saída para o display [bcd -> 7 segmentos]
                      output enb_next,	// Próximo bloco será ativado ou não
                      input enb,	// Bloco ativado ou não
                      input rst,	// Reset
                      input clk,	// Clock
                      input ld);	// Load
    wire [3:0] bcd_out;	// Valor bcd do registrador para o display [bcd -> 7 segmentos]
    wire [3:0] bcd_in;	// Valor bcd que sai do contador para o registrador
  	counter_bcd cnt_bcd(bcd_in, enb_next, clk, enb, rst);	// Módulo do contador
  	reg_4bit r4b(bcd_out, ld, clk, bcd_in);	// Módulo do registrador
    bcd27seg bcd_to_7seg(a, b, c, d, e, f, g, bcd_out);	// Módulo do display [bcd -> 7 segmentos]

endmodule

// Módulo do contador
module counter_bcd( output reg [3:0] bcd,	// Saída do valor para o registrador
                    output cnt_to_9,   	// Flag para saber se a contagem chegou em 9 ou não
                    input clk,	// Clock
                    input enb,	// Contador ativado ou não
                    input rst);	// Reset
	
	initial begin	// Inicializa os valores
    	bcd = 0;	// Valor de 0 a 9
    	cnt_to_9 = 1'b0;	// Flag para saber se chegou até 9
  	end

    always @(posedge clk) begin
        if (rst) begin	// Estado inicial caso reset esteja ativado
        	bcd = 0;
        	cnt_to_9 = 1'b0; 
        end
		else if (enb) begin // Conta de 0 a 9 se estiver ativado (e reset não ativado)
        	if (bcd == 9) begin		// Valor chegou em 9
            	bcd = 0;
        	end else begin
            	bcd++;
        	end
        
        	cnt_to_9 = (bcd == 9)? 1'b1 : 1'b0; // Ativa ou não o próximo bloco
        end 
    end

endmodule