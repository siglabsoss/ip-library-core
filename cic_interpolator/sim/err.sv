// err is a package that can be used to track errors in simulation

`ifndef ERRORS_SV_SV
`define ERRORS_SV_SV

package err;

    integer error_count;

    function void reset;
        error_count = 0;
    endfunction: reset

    function void increment;
        error_count++;
    endfunction: increment

    function integer get_count;
        return error_count;
    endfunction: get_count

    function void report_success_or_failure;
        if (error_count == 0) begin
            $display("<<TB_SUCCESS>>");
        end else begin
            $display("FAILURE! Error count = %d", error_count);
        end
    endfunction: report_success_or_failure

endpackage: err

`endif
