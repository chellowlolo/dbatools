function Get-JobList {
	<#
	.SYNOPSIS
		Helper function to get SQL Agent jobs.
	.DESCRIPTION
		Helper function to get all SQL Agent jobs or provide filter
	.PARAMETER SqlInstance
		SQL Server instance
	.PARAMETER SqlCredential
		Credential to use if SqlInstance did not include it.
	.PARAMETER Filter
		Object of jobs to filter on, also supports wildcard patterns
	.PARAMETER Not
		Reverse results where object returned excludes filtered content.
	.PARAMETER Silent
		Shhhhhhh
	.EXAMPLE
		Get-JobList -SqlInstance sql2016

		Returns the full JobServer.Jobs object found on sql2016
	.EXAMPLE
		Get-JobList -SqlInstance sql2016 -Filter '*job*'

		Returns the Job object for each job name found to have "job" in the name on sql2016
	.EXAMPLE
		Get-JobList -SqlInstance sql2016 -Filter '*job*' -Not

		Returns any Job object that does not have "job" in the name on sql2016
	.EXAMPLE
		Get-JobList -SqlInstance YourServer -Filter 'JobName'

		Returns the Job object where the job name is 'JobName' on sql2016
	.EXAMPLE
		Get-JobList -SqlInstance YourServer -Filter 'JobName' -Not

		Returns any Job object where the job name is not 'JobName' on sql2016
	.EXAMPLE
		Get-JobList -SqlInstance YourServer -Filter job_3_upload, job_3_download

		Returns the Job object for where job is job_3_upload or job_3_download on sql2016
	.EXAMPLE
		Get-JobList -SqlInstance YourServer -Filter job_3_upload, job_3_download -Not

		Returns any Job object where job is not job_3_upload or job_3_download on sql2016
	.NOTES
		Original Author: Shawn Melton (@wsmelton)

		Website: https://dbatools.io
		Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
		License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
	#>
	[cmdletbinding()]
	param(
		[Parameter(ValueFromPipeline = $true)]
		[DbaInstanceParameter]$SqlInstance,
		[PSCredential]$SqlCredential,
		[string[]]$Filter,
		[switch]$Not,
		[switch]$Silent
	)
	process {
		$server= Connect-SqlInstance -SqlInstance $SqlInstance -SqlCredential $SqlCredential

		$jobs = $server.JobServer.Jobs
		if (Test-Bound 'Filter') {
			if ($Filter.Count -gt 1) {
				if ($Not) {
					$jobs | Where-Object Name -NotIn $Filter
				}
				else {
					$jobs | Where-Object Name -In $Filter
				}
			}
			else {
				foreach ($job in $jobs) {
					if ($Filter -match '`*') {
						if ($Not) {
							$job | Where-Object Name -NotLike $Filter
						}
						else {
							$job | Where-Object Name -Like $Filter
						}
					}
					else {
						if ($Not) {
							$job | Where-Object Name -ne $Filter
						}
						else {
							$job | Where-Object Name -eq $Filter
						}
					}
				}
			}
		}
	}
}