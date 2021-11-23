firstLine=1
hasAtLeastOneVersion=0
hasAtLeastOneTypeOfChange=0
hasAtLeastOneComment=0
exitFlag=0
hasComment=1
hasTypeOfChange=1
nonstandardHeader=0

while IFS= read -r line; do
  if [[ $firstLine == 1 ]]; then
    # ensure first line says changelog
    if [[ ! "$line"  =~ ^\#[[:space:]]Changelog ]]; then
      echo -e "\e[31mError: Changelog must start with '# Changelog'. For correct formatting, see https://keepachangelog.com/en/1.0.0/ \e[0m"
      exitFlag=1
    fi
    firstLine=0
  fi
  # Check for version/section header
  if [[ "$line" =~ ^\#\#[[:space:]].+ ]]; then
    if [[ "$line" =~ ^\#\#[[:space:]]\[[[0-9]+\.[0-9]+\.[0-9]+.*\].* ]]; then
      # version header
      if [[ $hasTypeOfChange == 0 ]]; then
        echo -e "\e[31mError: Changelog - version $prevVersion is missing a changetype header. For correct formatting, see https://keepachangelog.com/en/1.0.0/ \e[0m"
        exitFlag=1
      fi
      hasTypeOfChange=0
      hasAtLeastOneVersion=1
      if [[ $nonstandardHeader == 0 ]]; then
        prevVersion=$line
      else
        # we had been ignoring the lines above this (IE malformed version) -- keep prevVersion the same
        nonstandardHeader=0
      fi
    elif [[ "$line" =~ ^\#\#[[:space:]]\[[a-zA-Z]+\] ]]; then
      # section header
      # don't want to count anything below section title
      nonstandardHeader=1
    else
      echo -e "\e[31mError: Changelog header $line is in the wrong format. For correct formatting, see https://keepachangelog.com/en/1.0.0/ \e[0m"
      exitFlag=1
      # malformed header, set to make sure we don't count anything that comes after it
      nonstandardHeader=1
    fi
  fi
  # Check for changetype
  if [[ "$line" =~ ^\#\#\#[[:space:]]+ && $nonstandardHeader == 0 ]]; then
    hasAtLeastOneTypeOfChange=1
    hasTypeOfChange=1
    if [[ $hasComment == 0 ]]; then
      echo -e "\e[31mError: Changelog - version $prevVersion is missing a comment for the [$prevChangetype] changetype. For correct formatting, see https://keepachangelog.com/en/1.0.0/ \e[0m"
      exitFlag=1
    fi
    hasComment=0
    prevChangetype=$line
  fi
  # Check for comment
  if [[ "$line" =~ ^[[:space:]]*-[[:space:]] && $nonstandardHeader == 0 ]]; then
    hasAtLeastOneComment=1
    hasComment=1
  fi
done < ./CHANGELOG.md
# check final section format
if [[ $hasComment == 0 ]]; then
  echo -e "\e[31mError: Changelog - version $prevVersion is missing a comment. For correct formatting, see https://keepachangelog.com/en/1.0.0/ \e[0m"
  exitFlag=1
fi
if [[ $hasTypeOfChange == 0 ]]; then
  echo -e "\e[31mError: Changelog - version $prevVersion is missing a changetype header. For correct formatting, see https://keepachangelog.com/en/1.0.0/ \e[0m"
  exitFlag=1
fi
# check globally if sections are missing
if [[ $hasAtLeastOneVersion == 0 ]]; then
  echo -e "\e[31mError: Changelog is missing the app version (IE '## [1.0.0]') or is formatted incorrectly. For correct formatting, see https://keepachangelog.com/en/1.0.0/ \e[0m"
  exitFlag=1
fi
if [[ $hasAtLeastOneTypeOfChange == 0 ]]; then
  echo -e "\e[31mError: Changelog is missing the changetype (IE '### Added' or '### Changed') or is formatted incorrectly. For correct formatting, see https://keepachangelog.com/en/1.0.0/ \e[0m"
  exitFlag=1
fi
if [[ $hasAtLeastOneComment == 0 ]]; then
  echo -e "\e[31mError: Changelog is missing comments or they are formatted incorrectly. For correct formatting, see https://keepachangelog.com/en/1.0.0/ \e[0m"
  exitFlag=1
fi
if [[ $exitFlag == 1 ]]; then
  exit 1
else
  echo "Changelog is valid"
fi
