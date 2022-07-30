`timescale 1 ns/100 ps	//Tirar no DigitalJS

// Módulo da máquina de estados
module state_machine( output ch_Vm,	// Tensão a ser medida
                        output ch_ref,	// Tensão de referência
                        output ch_zr,	// Chave que leva a saída do integrador a zero
                        output ld,	// Load
                        output rst,	// Reset
                        output enb_cnt,	// Inicia ou não a contagem
                        input start,	// Início
                        input clk,	// Clock
                        input enb_machine,	// Sinaliza o fim da contagem
                        input Vint_z);	// Tensão de saída do integrador
  	
	reg [1:0] next_state;	// Próximo estado
	reg operant;	// Máquina em estado operante

  	initial begin	// Inicializar estado
      next_state = 2'b00;
    end
  
  	always @(posedge clk) begin
    	// Inicializa a máquina
    	if(start) begin
    		operant = 1'b1; // Estado operante está ativado
    		rst = 1'b0; // Desabilita o reset do contador
    		ch_zr = 1'b0; // Abre a chave para descarregar o capacitor
    	end

    	// Sistema inicializado
    	if(operant == 1'b1) begin
			case (next_state)
				2'b00: begin
					enb_cnt = 1'b1;	// Contagem iniciada
    				ch_Vm = 1'b1;	// Ativa a chave de medição da tensão
					next_state = 2'b01;	// Altera próximo estado
				end
				2'b01: begin
					if (enb_machine) begin
						ch_Vm = 1'b0;	// Desativa a chave Vm
    					ch_ref = 1'b1;	// Ativa a chave de referência
    					next_state = 2'b10;	// Altera próximo estado
					end
				end
				2'b10: begin
					if (Vint_z) begin
						enb_cnt = 1'b0;	// Desativa a contagem
    					ld = 1'b1;	// Ativa o load
    					ch_ref = 1'b0;	// Destiva a chave de referência
    					next_state = 2'b11;	// Altera próximo estado
					end
				end
				2'b11: begin
					ld = 1'b0;	// Desativa o load
    				rst = 1'b1;	// Ativa o reset
    				ch_zr = 1'b1;	// Ativa a chave que leva a saída a zero
    				operant = 1'b0;	// Desliga a máquina
					next_state = 2'b00; // Estado inicial
				end
				default: begin
					next_state = 2'b00;	// Estado inicial
				end
			endcase
		end		
	end

endmodule