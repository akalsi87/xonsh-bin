#!/bin/bash

tag=0.19.4
version=3.11
build_num=1
url=https://github.com/scc-tw/standalone-python/releases/download/release-2024-04-29/release-${version}-x86_64.tar.gz

mkdir -p .python/
[ -f .python/opt/python/bin/python3 ] || {
  # download the standalone Python release
  wget $url -O standalone-python.tar.gz
  if [ $? -ne 0 ]; then
    echo "Failed to download standalone Python from $url"
    exit 1
  fi

  tar -xzf standalone-python.tar.gz -C .python
  if [ $? -ne 0 ]; then
    echo "Failed to extract standalone Python"
    exit 1
  fi
}

export PATH=$(pwd)/.python/opt/python/bin:$PATH

pip3 install 'xonsh[full]'
if [ $? -ne 0 ]; then
  echo "Failed to install xonsh"
  exit 1
fi
# create a standalone xonsh shell script
cat > xon.sh <<EOF
#!/bin/bash
curdir=\$(dirname "\$BASH_SOURCE[0]")
export PATH=\$curdir/.python/opt/python/bin:\$PATH

exec \$curdir/.python/opt/python/bin/python${version}-real -m xonsh "\$@"
EOF
chmod +x xon.sh
ln -sfn ./xon.sh ./xonsh

# create a custom tar file with maximum compression level
tar_file="xonsh-${tag}-py-${version}-x86_64-${build_num}.tar.gz"
GZIP=-9 tar -czf $tar_file xonsh xon.sh .python
if [ $? -ne 0 ]; then
  echo "Failed to create tar file"
  exit 1
fi
echo "Standalone xonsh build completed successfully."
echo "You can now use the xonsh script to run xonsh with the standalone Python."
echo "To run xonsh, use: ./xonsh"
