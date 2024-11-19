#disable telemetry
Set-GitHubConfiguration -DisableTelemetry

#set defaults if env's not set
if (!$ENV:GITHUB_ORG_REPO_TYPE) { $ENV:GITHUB_ORG_REPO_TYPE = "all" }
if (!$ENV:GITHUB_INCLUDE_WIKI) { $ENV:GITHUB_INCLUDE_WIKI = "yes" }
if (!$ENV:GITHUB_INCLUDE_ISSUES) { $ENV:GITHUB_INCLUDE_ISSUES = "yes" }

if ($ENV:GITHUB_ORG -and $ENV:GITHUB_TOKEN) {

    $repos = Get-GitHubRepository -AccessToken $ENV:GITHUB_TOKEN -Type $ENV:GITHUB_ORG_REPO_TYPE

}
elseif ($ENV:GITHUB_REPOS) {
    $repolist = $ENV:GITHUB_REPOS.split(',')
    $repos = $repolist | ForEach-Object {
        Get-GitHubRepository -AccessToken $ENV:GITHUB_TOKEN -Uri $_
    }
}

if($ENV:GITHUB_BACKUPSTARS -eq "True"){
    function Get-GitHubStars {
        param (
            [string]$Token,
            [string]$BaseUrl = "https://api.github.com",
            [int]$PerPage = 30
        )
    
        # Initialize variables
        $headers = @{ 
            Authorization = "token $Token"
            Accept = "application/vnd.github.v3+json"
        }
        $stars = @()
        $page = 1
    
        # Loop through pages until all results are retrieved
        do {
            $url = "$BaseUrl/user/starred?per_page=$PerPage&page=$page"
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
            
            # Add results to the array
            $stars += $response
            
            # Check if the response has content
            $hasMoreData = $response.Count -eq $PerPage
            $page++
        } while ($hasMoreData)
    
        # Return all starred repositories
        return $stars
    }
    $allStars=Get-GitHubStars -Token $ENV:GITHUB_TOKEN
    $repos+=$allStars.html_url | ForEach-Object {
        Get-GitHubRepository -AccessToken $ENV:GITHUB_TOKEN -Uri $_
    }

}


#ERROR IF 0 REPOS are detected
if($repos.count -eq 0){"FATAL ERROR: 0 REPOS FOUND OR SELECTED"}

#Perform mirror
$repos |where {$_ -like "**"} | ForEach-Object -parallel {
    #Create dir for each repo
    cd $ENV:SOURCEDIR
    New-Item -ItemType Directory -Path $($_.full_name.replace('/','_').replace('.','_').replace('.','_'))
    cd $($_.full_name.replace('/','_').replace('.','_'))
    #"STARTING MAIN EXPORT"
    $repo = $_.RepositoryUrl.replace("https://", "https://$($ENV:GITHUB_USERNAME):$($ENV:GITHUB_TOKEN)@")
    $path = join-path -Path $((get-location).path) -ChildPath "$($_.full_name.replace('/','_').replace('.','_'))"
    New-Item -ItemType Directory -Path $path -ErrorAction SilentlyContinue | out-null
    $args = "clone --quiet --mirror $repo $path"
    Start-Process git -Wait -ArgumentList $args -NoNewWindow 
    $tarargs="-cf $path.tar -C $((get-location).path) $($_.full_name.replace('/','_').replace('.','_'))"
    Start-Process tar -Wait -ArgumentList $tarargs -NoNewWindow  
    "repo exported for $($_.full_name)"
    remove-item -Path $path -Recurse -Force | out-null
    #Add wiki's to export

    #"STARTING WIKIEXPORT"
    if ($ENV:GITHUB_INCLUDE_WIKI -eq "yes") {
        if($_.has_wiki -eq "true"){
            $wikirepo="$($_.RepositoryUrl.replace("https://", "https://$($ENV:GITHUB_USERNAME):$($ENV:GITHUB_TOKEN)@")).wiki.git"
            $wikipath = join-path -Path $((get-location).path) -ChildPath "$($_.full_name.replace('/','_').replace('.','_'))_wiki"
            New-Item -ItemType Directory -Path $wikipath -ErrorAction SilentlyContinue | out-null
            $wikiargs = "clone --quiet --mirror $wikirepo $wikipath"
            Start-Process git -Wait -ArgumentList $wikiargs -NoNewWindow -RedirectStandardError /dev/null
            if((gci $wikipath).count -gt 0){
                $tarargs="-cf $wikipath.tar -C $((get-location).path) $($_.full_name.replace('/','_').replace('.','_'))_wiki"
                Start-Process tar -Wait -ArgumentList $tarargs -NoNewWindow  
                "wiki exported for $($_.full_name)"
            }
            remove-item -Path $wikipath -Recurse -Force
        }
    }

    #"STARTING ISSUE EXPORT"
    if($ENV:GITHUB_INCLUDE_ISSUES -eq "yes"){
        if($_.has_issues -eq "true"){
            $issues=$null
            $issues=Get-GitHubIssue -uri $_.RepositoryUrl -AccessToken $ENV:GITHUB_TOKEN -State all
            if($issues.count -gt 0){
                $issues | convertto-json -Depth 20 | out-file (join-path -Path $((get-location).path) -ChildPath "$($_.full_name.replace('/','_').replace('.','_'))_issues.json")
                #Removed, bugs out if there are to many comments, and is very slow to return the results
                #$issues | Get-GitHubIssueComment -AccessToken $ENV:GITHUB_TOKEN | ConvertTo-Json -Depth 20 | out-file (join-path -Path $ENV:SOURCEDIR -ChildPath "$($_.full_name.replace('/','_').replace('.','_'))_issue_comments.json")
            }
            "$($issues.count) issues found for $($_.full_name) and exported"
        }
    }
#go back to root directory
cd $ENV:SOURCEDIR
}
