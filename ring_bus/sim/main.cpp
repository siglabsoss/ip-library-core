#include "Vring_bus_sim.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vring_bus_sim_ring_bus_sim.h"
#include <iostream>
#include <cstdint>

using namespace std;

/* DEFINITIONS */

typedef Vring_bus_sim top_t;

#define TEST_READ_OF    0
#define TEST_READ       0
#define TEST_PASSTHU    0
#define TEST_WRITE      0
#define TEST_WRITE_BUSY 0

#define TEST_BANG       1


/* DECLARATIONS */

char my_test_msg_1[] = {2,2,3,3,                                                             // start bits
                0,0,0,0, 0,0,0,0,                                                            // time to live = 0
                1,1,0,0, 0,0,0,0,  0,0,0,0, 0,1,0,0,   0,0,0,0, 0,0,0,0,  0,0,0,0, 0,0,0,1}; // payload


char my_test_msg_2[] = {2,2,3,3,                                                             // start bits
                0,0,0,0, 0,0,0,0,                                                            // time to live = 0
                1,1,0,0, 0,0,0,0,  1,1,1,1, 0,1,0,0,   0,0,0,0, 1,0,0,1,  1,0,1,0, 0,0,0,1}; // payload


char neighbor_test_vec_1[] = {2,2,3,3,                                                       // start bits
                0,0,0,0, 0,0,0,1,                                                            // time to live = 1
                1,1,1,1, 0,0,0,0,  1,0,1,0, 0,1,0,1,   1,1,0,0, 0,0,1,1,  0,0,1,1, 1,1,0,0}; // payload


char neighbor_test_vec_2[] = {2,2,3,3,                                                       // start bits
                0,0,0,0, 0,0,1,0,                                                            // time to live = 2
                1,1,1,1, 0,0,0,0,  1,1,1,1, 1,1,1,1,   1,1,0,0, 1,1,1,1,  0,0,1,1, 1,1,1,1}; // payload


int32_t trace_timestamp = 0;


VerilatedVcdC* g_tfp;


top_t* g_top;


void ticktock(unsigned n) // n system ticks
{
    int i;

    for (i = 0; i < 2 * n; i++)
    {
        g_tfp->dump(trace_timestamp++);
        g_top->i_sysclk = !g_top->i_sysclk;
        g_top->eval();
    }
}


void send_test_vec(char* v, uint32_t n)
{
    uint32_t i;
    for (i = 0; i < n; i++) {
        switch (v[i]) {
            case 0:
                g_top->i_serial_bus = 0; // manchester coding '0'
                break;
            case 1:
                g_top->i_serial_bus = 1; // manchester coding '1'
                break;
            case 2:
                g_top->i_serial_bus = 1; // manchester coding 'stop'
                break;
            case 3:
                g_top->i_serial_bus = 0; // manchester coding 'start'
                break;
            default:
                break;
        }

        ticktock(6);

        switch (v[i]) {
            case 0:
                g_top->i_serial_bus = 1; // manchester coding '0'
                break;
            case 1:
                g_top->i_serial_bus = 0; // manchester coding '1'
                break;
            case 2:
                g_top->i_serial_bus = 1; // manchester coding 'stop'
                break;
            case 3:
                g_top->i_serial_bus = 0; // machester coding 'start'
            default:
                break;
        }

        ticktock(6);
    }

    g_top->i_serial_bus = 1;
}

uint32_t write_32_bit_test_vec(char* v)
{
    uint32_t i, ret;

    ret = 0;

    for (i = 0; i < 32; i++)
        if(1 == v[31-i])
            ret |= 1 << i;

    return ret;
}

uint8_t write_8_bit_test_vec(char* v)
{
    uint8_t ret, i;

    ret = 0;

    for (i = 0; i < 8; i++)
        if(1 == v[7-i])
            ret |= 1 << i;

    return ret;
}

int main(int argc, char **argv, char **env) {
    int clk, i;
    int cmd [] = {
        0, 0, 0, 0, 0
    };


    cout << "starting verilator simulation" << endl;

    Verilated::commandArgs(argc, argv);
    // init top verilog instance
    g_top = new top_t;
    // init trace dump
    Verilated::traceEverOn(true);
    g_tfp = new VerilatedVcdC;


    g_top->trace (g_tfp, 99);
    g_tfp->open ("ring_bus.vcd");


    // Initial Conditions
    g_top->i_sysclk = 1;
    g_top->i_srst = 1;
    g_top->i_serial_bus = 1;


    // Test Sequence

    g_top->eval();

    ticktock(3);

    g_top->i_srst = 0;

    ticktock(20);


    /*****
     * TEST THE READ OVERFLOW
     *
     * Send two messages back to back and make sure overflow flag is set.
     * Then make sure the overflow flag can be cleared
     *****/

    if( TEST_READ_OF ) {

        send_test_vec(my_test_msg_1, sizeof(my_test_msg_1));

        ticktock(20);

        send_test_vec(my_test_msg_1, sizeof(my_test_msg_1));

        ticktock(200);

        // NOW CLEAR IT

        g_top->i_clear_flags = 1;

        ticktock(1);

        g_top->i_clear_flags = 0;

    }


    /*****
     * TEST READ
     *****/

    if( TEST_READ ) {

        send_test_vec(my_test_msg_2, sizeof(my_test_msg_2));

        ticktock(100);

        g_top->i_clear_flags = 1;

        ticktock(1);

        g_top->i_clear_flags = 0;

        ticktock(100); }




    /*****
     * TEST PASSTHRU
     *****/

    if( TEST_PASSTHU ) {

        send_test_vec(neighbor_test_vec_1, sizeof(neighbor_test_vec_1));

        ticktock(800);

    }




    /*****
     * TEST WRITE
     *****/

    if( TEST_WRITE ) {

        g_top->i_wr_data = write_32_bit_test_vec(neighbor_test_vec_2 + 12);
        g_top->i_wr_addr = write_8_bit_test_vec(neighbor_test_vec_2 + 4);
        g_top->i_start_wr = 1;

        ticktock(1);
        g_top->i_start_wr = 0;

        ticktock(800);
    }



    /*****
     * TEST WRITE BUSY
     *****/

    if( TEST_WRITE_BUSY ) {

        // first have data going through bus

        send_test_vec(neighbor_test_vec_1, sizeof(neighbor_test_vec_1));

        // the immedately request write
        g_top->i_wr_data = write_32_bit_test_vec(neighbor_test_vec_2 + 12);
        g_top->i_wr_addr = write_8_bit_test_vec(neighbor_test_vec_2 + 4);
        g_top->i_start_wr = 1;

        ticktock(1);
        g_top->i_start_wr = 0;

        ticktock(800);
    }


    /*****
     * TEST BANG
     *****/

    if( TEST_BANG ) {

        for( i = 0; i < 10; i++)
        {
            g_top->i_wr_data = write_32_bit_test_vec(neighbor_test_vec_2 + 12);
            g_top->i_wr_addr = write_8_bit_test_vec(neighbor_test_vec_2 + 4);

            g_top->i_start_wr = 1;
            ticktock(1);
            g_top->i_start_wr = 0;
            ticktock(1);

            while(0 == g_top->o_done_wr)
                ticktock(50);
        }
        ticktock(800);
    }


    ticktock(8000);

    // Write Wavefile

    g_tfp->close();


    return 0;
}
