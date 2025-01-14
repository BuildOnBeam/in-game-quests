
test:
	forge test

coverage:
	forge clean && forge coverage --no-match-coverage script --report debug > coverage_report.txt
