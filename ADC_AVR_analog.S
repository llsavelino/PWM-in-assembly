#include <avr/io.h>
; Inclui as definições de I/O do AVR

; Organização da memória - define a origem para 0x0000 (vetor de reset)
.ORG 0x0000
  RJMP init_ADC           ; Pula para init_ADC no reset

.text                     ; Início da seção de código

; Declaração de símbolos globais
.global init_ADC          ; Torna init_ADC acessível globalmente
.global read_ADC          ; Torna read_ADC acessível globalmente

;=-=-=-=-=-=-=-=-=-=-=-=-=-
; 1. Registrador ADMUX (ADC Multiplexer Selection Register)
; Endereço: 0x7C
; Bits: REFS1 | REFS0 | ADLAR | MUX4 | MUX3 | MUX2 | MUX1 | MUX0
; Sub-rotina de inicialização do ADC
;::::::::::::::::::::::::::
; 2. Registrador ADCSRA (ADC Control and Status Register A)
; Endereço: 0x7A
; Bits: ADEN | ADSC | ADATE | ADIF | ADIE | ADPS2 | ADPS1 | ADPS0
init_ADC:
  ;+-+-+-+-+-+-+-+-+-+-+-+-
  
  ; Configuração das portas
  LDI r17, 0b11111111     ; Carrega 255 (todos os bits em 1) no registrador r17
  OUT DDRB, r17           ; Define todos os pinos da PORTB como SAÍDA
  OUT DDRD, r17           ; Define todos os pinos da PORTD como SAÍDA
  
  ; Configura o pino de entrada do ADC
  COM r17                 ; Inverte os bits do r17 (agora 0b00000000)
  OUT DDRC, r17           ; Define todos os pinos da PORTC como ENTRADA (usaremos apenas PC0/ADC0)
  CLR r17                 ; Limpa r17 (opcional, define como 0b00000000)
  
  ; Configura o ADC
  LDI r17, 0b11000000     ; Define tensão de referência (interno 2.65V), resultado ajustado à direita, seleciona canal ADC0
  STS ADMUX, r17          ; Armazena no registrador ADMUX na SRAM
  
  LDI r17, 0b10000111     ; Habilita o ADC, define prescaler para CLK/128
  STS ADCSRA, r17         ; Armazena no registrador ADCSRA na SRAM
  
  RET                     ; Retorna da sub-rotina

;=-=-=-=-=-=-=-=-=-=-=-=-=-
; Sub-rotina de leitura do ADC
read_ADC:
  ;+-+-+-+-+-+-+-+-+-+-+-+-
  
  ; Inicia a conversão do ADC
  LDI r17, 0b11000111     ; Seta o bit ADSC (inicia conversão) mantendo outras configurações
  STS ADCSRA, r17         ; Armazena no ADCSRA para iniciar a conversão

  ; Aguarda a conclusão da conversão
  wait_ADC:
    LDS r21, ADCSRA       ; Carrega o status do ADCSRA no registrador r21
    SBRS r21, 0b00000100  ; Pula a próxima instrução se o bit ADIF (conversão completa) estiver setado
    RJMP wait_ADC         ; Se não estiver setado, continua aguardando
    
    ; Limpa a flag ADIF escrevendo 1 nela (conforme o datasheet)
    CLR r21               ; Limpa r21 (opcional)
    LDI r21, 0b11010111   ; Seta o bit ADIF (bit 4) para limpá-lo, mantendo outras configurações
    STS ADCSRA, r21       ; Armazena no ADCSRA
    
    ; Lê e exibe o resultado do ADC
    LDS r18, ADCL         ; Lê o byte baixo do resultado do ADC
    LDS r19, ADCH         ; Lê o byte alto do resultado do ADC
    OUT PORTD, r18        ; Envia o byte baixo para a PORTD
    OUT PORTB, r19        ; Envia o byte alto para a PORTB
    
  RET                     ; Retorna da sub-rotina