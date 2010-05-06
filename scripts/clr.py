#!/usr/bin/python
# http://www.informatik-forum.at/showthread.php?73283-SCRIPT-Einf%E4rben-von-Assembler-Code
# Einfaerben von amd64 Assembler-Code
# thp/a\thpinfo.com; 2009-05-22

import sys
import re

# Farbcodes siehe http://www.pixelbeat.org/docs/terminal_colours/
colorify = (
        # Return-Register: violett
        (r'()(%rax)()', '35'),
        # Argument-Register: gruen
        (r'()(%rdi|%rsi|%rdx|%rcx|%r8|%r9)()', '32'),
        # Temporary Register: gelb
        (r'()(%r10|%r11|%xmm\d{1,2})()', '33'),
        # Callee-saved Register: rot
        (r'()(%rbx|%r15|%r14|%r13|%r12)()', '31'),
        # Stack- u. Frame-Pointer: grau
        (r'()(%rsp|%rbp)()', '1;30'),
        # Zahlenwerte: tuerkis
        (r'()(\$[-]?\d+)()', '36'),
        # Disposition von M/R-Berechnungen: tuerkis
        (r'()([-]?\d+)(\([^)]*\))', '36'),
        # Scale von M/R-Berechnungen: tuerkis
        (r'(,[ ]?)(1|2|4|8)(\))', '36'),
)

for line in sys.stdin:
    for match, color in colorify:
        line = re.sub(match, '\\1\033['+color+'m\\2\033[0m\\3', line)
    sys.stdout.write(line)
