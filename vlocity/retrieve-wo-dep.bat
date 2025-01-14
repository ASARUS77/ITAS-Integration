@echo off
IF exist vlocity (
	robocopy  vlocity archive/vlocity-%2-%3 /E
	rd vlocity /s /q
)

vlocity -sfdx.username %1 -job packExport.yaml packExport
