module.exports = {
    top: 'downconverter',
    topFile: 'downconverter.sv',
    clk: 'i_clock',
    reset: 'i_reset', // active high
    targets: [{
        data:  'i_inph_data',
        valid: 'i_valid',
        ready: 't_0_ack',
        formula: width => {
            const words = (width / 32) >>> 0;
            return () => {
                let res = '';
                for (let i = 0; i < words; i++) {
                    res += ('000000' +
                        (Math.pow(2, 32) * Math.random() >>> 0)
                    ).slice(-8)
                }
                return res;
            };
        },
        width: 16,
        length: 1500000,
        formula: width => i => i,
    },{
        data:  'i_inph_delay_data',
        valid: 'i_valid',
        ready: 't_1_ack',
        formula: width => {
            const words = (width / 32) >>> 0;
            return () => {
                let res = '';
                for (let i = 0; i < words; i++) {
                    res += ('000000' +
                        (Math.pow(2, 32) * Math.random() >>> 0)
                    ).slice(-8)
                }
                return res;
            };
        },
        width: 16,
        length: 128,
        formula: width => i => i,
    }],
    initiators: [{
        data:  'o_inph_data',
        valid: 'o_valid',
        ready: 'i_0_ack',
        width: 16
    },{
        data:  'o_quad_data',
        valid: 'o_valid',
        ready: 'i_0_ack',
        width: 16
    }]
};
