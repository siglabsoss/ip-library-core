'use strict';

const templates = require('../lib/templates.js');
const range = require('lodash.range');
const yargs = require('yargs');
const path = require('path');
const fs = require('fs-extra');

const pos = props =>
    props.positional('project', {
        describe: 'project description file (JS or JSON)',
        type: 'string'
    }).positional('output', {
        describe: 'path to the output files',
        type: 'string'
    });

const generateTb = props => {
    pos(props);
    const argv = props.argv;
    const projPath = path.resolve(argv.project);
    const outputPath = path.resolve(argv.output || path.dirname(argv.project));
    const proj = require(projPath);

    Object.keys(templates).map(fileName => {
        const fn = templates[fileName];
        const body = fn(proj);
        fs.outputFile(path.resolve(outputPath, fileName), body, errW => {
            if (errW) {
                throw errW;
            }
        });
    });
};

const generateData = props => {
    pos(props);
    const argv = props.argv;
    const projPath = path.resolve(argv.project);
    const outputPath = path.resolve(argv.output || path.dirname(argv.project));
    const proj = require(projPath);

    proj.targets.map(t => {
        const filePath = path.resolve(outputPath, t.data + '.mif');
        const dataLength = t.length || 32;
        const width = t.width || 8;
        const formula = t.formula || proj.formula || (width => () => Math.pow(2, width) * Math.random() >>>0);
        const data = range(dataLength).map(formula(width)).map(e => e.toString(16)).join('\n');
        fs.outputFile(filePath, data, errW => {
            if (errW) {
                throw errW;
            }
        });
    });
};

yargs
    .command(
        ['gen [project] [output]', 'generate'],
        'Generate verilator testbench',
        generateTb
    )
    .command(
        ['mif [project] [output]', 'input'],
        'Generate input data files',
        generateData
    )
    .alias('p', 'project')
    .alias('o', 'output')
    .usage('Usage: $0 <command> [options]')
    .argv;
