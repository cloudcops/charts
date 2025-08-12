files_changed="$(git show --pretty="" --name-only)"
# Adding || true to avoid "Process exited with code 1" errors
charts_dirs_changed="$(echo "$files_changed" | xargs dirname | grep -o "bitnami/[^/]*" | sort | uniq || true)"
# Using grep -c as a better alternative to wc -l when dealing with empty strings."
num_charts_changed="$(echo "$charts_dirs_changed" | grep -c "bitnami" || true)"
num_version_bumps="$(echo "$files_changed" | grep  "bitnami/[^/]*/Chart.yaml" | xargs git show | grep -c "+version" || true)"

if [[ "$num_charts_changed" -ne "$num_version_bumps" ]]; then
  # Changes done in charts but version not bumped -> ERROR
  charts_changed_str="$(echo ${charts_dirs_changed[@]})"
  echo "error=Detected changes in charts without version bump in Chart.yaml. Charts changed: ${num_charts_changed} ${charts_changed_str}. Version bumps detected: ${num_version_bumps}"
  echo "result=fail"
elif [[ "$num_charts_changed" -eq "1" ]]; then
  # Changes done in only one chart -> OK
  chart_name=$(echo "$charts_dirs_changed" | sed "s|charts/||g")
  echo "chart=${chart_name}"
  echo "result=ok"
else
  # Changes done in more than chart -> FAIL
  charts_changed_str="$(echo ${charts_dirs_changed[@]})"
  echo "error=Changes detected in more than one chart directory: ${charts_changed_str}. The publish process will be stopped. Please create different commits for each chart."
  echo "result=fail"
fi