
# ECP5 Slave Serial Programmer

## Purpose 

Slave serial programmer for programming lattice ECP5 in slave serial mode.
It expects to be fed one byte at a time and will ACK each byte after it
shifts it out to the FPGA being programmed. 
It keeps track of the number of bytes it has been fed and knows when it's
done.

## Notes

* Set the parameter P_CONFIG_BYTES to the number of bytes that constitute the FPGA programming file (e.g. the bit file)
* Lattice bit file size varies depending on the design, so it's recommended that you zero pad the bit file so it's always the max bit file
  size for the ECP5 part you are targeting.

## Warnings

* The provided clock should be 100MHz or less to avoid Slave Serial programming timing violations.

## TODOs

* Add parameter and logic to divide down the provided clock in order to eliminate the current 100MHz limit on the provided clock while
  still meeting Slave Serial programming timing requirements.
