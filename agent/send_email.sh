#!/bin/sh

facter --json |mail -s facts roro@dahu.com 
