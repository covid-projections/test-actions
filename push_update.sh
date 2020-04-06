now=$(date)
git config --local user.email "action@github.com"                                            
git config --local user.name "GitHub Action"                                                 
git add -A                                                                                   
git commit -m "Update source data at $now"                                                   
git push "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" HEAD:${GITHUB_REF}    
