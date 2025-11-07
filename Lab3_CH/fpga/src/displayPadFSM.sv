/*
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/18/2025
	
	This finite state machine scans a 4x4 keypad by sequentially activating each column (sweep) 
	and monitoring the row inputs (rowDataIn) to detect a key press. When a button is pressed and verified, 
	it decodes the corresponding key value and updates the two-digit display, shifting the previous key to 
	the left and showing the new one on the right. The FSM also holds the display until no key is pressed, 
	ensuring stable and debounced input.
	
	Inputs: clk, reset, rowDataIn[3:0]
	Outputs: sweep[3:0], display[7:0]

*/
module displayPadFSM (
    input  logic       clk, reset,
    input  logic [3:0] rowDataIn,
    output logic [3:0] sweep,
    output logic [7:0] display
);

    typedef enum logic [3:0] {
        DELAY1, DELAY2, SWEEP0, SWEEP1, SWEEP2, SWEEP3,
        SET, VERIFY, DISPLAY, HOLD
    } state_t;

    state_t state, nextState;

    logic [3:0] holdRow, holdSweep;
    logic [3:0] firstHalf, secondHalf, decodedKey;
    logic [3:0] sweep_d1, sweep_d2;
    logic       enable, holdEnable, high, low, holdLow, exitSweep;

    // Submodules
    deBounce debounceCall(clk, reset, enable, rowDataIn, holdRow, high, low);
    keypadDecoder keypadDecoderCall(holdSweep, holdRow, decodedKey);
    holdKey   holdKeyCall(clk, reset, holdEnable, rowDataIn, holdLow);

    // Synchronize sweep signal (gives keypad time to settle) 
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            sweep_d1 <= 4'b1111;
            sweep_d2 <= 4'b1111;
        end else begin
            sweep_d1 <= sweep;
            sweep_d2 <= sweep_d1;
        end
    end

    // Exit condition: any row active after sweep settles
    assign exitSweep = (rowDataIn != 4'b0000);

    // Next-state logic
    always_comb begin
        nextState = state;
        unique case (state)
            DELAY1:    nextState = DELAY2;
            DELAY2:    nextState = SWEEP0;
            SWEEP0:    nextState = exitSweep ? SET : SWEEP1;
            SWEEP1:    nextState = exitSweep ? SET : SWEEP2;
            SWEEP2:    nextState = exitSweep ? SET : SWEEP3;
            SWEEP3:    nextState = exitSweep ? SET : SWEEP0;
            SET:       nextState = VERIFY;
            VERIFY:    nextState = high ? DISPLAY :
                                   low  ? DELAY1 : VERIFY;
            DISPLAY:   nextState = HOLD;
            HOLD:      nextState = holdLow ? DELAY1 : HOLD;
            default:   nextState = DELAY1;
        endcase
    end

    // State register & captured data
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            state      <= DELAY1;
            firstHalf  <= 0;
            secondHalf <= 0;
        end else begin
            state <= nextState;

            // Capture pressed key row/column
            if (nextState == SET) begin
                holdRow   <= rowDataIn;
                holdSweep <= ~sweep_d2;   // use delayed sweep like your original
            end

            // Update display data
            if (nextState == DISPLAY) begin
                secondHalf <= firstHalf;
                firstHalf  <= decodedKey;
            end
        end
    end

    // Output logic
    always_comb begin
        enable = 0;
        holdEnable = 0;
        sweep = 4'b1111;

        unique case (state)
            DELAY1:     sweep = 4'b1011;
            DELAY2:     sweep = 4'b0111;
            SWEEP0:     sweep = 4'b1110;
            SWEEP1:     sweep = 4'b1101;
            SWEEP2:     sweep = 4'b1011;
            SWEEP3:     sweep = 4'b0111;
            SET,
            VERIFY:     begin
                            enable = 1;
                            sweep = ~holdSweep; // keep column active
                        end
            DISPLAY,
            HOLD:       begin
                            holdEnable = 1;
                            sweep = 4'b0000;
                        end
        endcase
    end
    assign display = {secondHalf, firstHalf};
endmodule
