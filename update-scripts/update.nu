# to invoke generate_sources directly, enter nushell and run
# `use update.nu`
# `update generate_sources`

def get_nix_hash [url: string]: nothing -> string  {
  nix store prefetch-file --hash-type sha256 --json $url | from json | get hash
}

export def generate_sources []: nothing -> record {
  let tag = date now | format date "%Y%m%d"
  let prev_sources: record = open ./sources.json

  let x86_64_url = $"https://github.com/zen-browser/desktop/releases/download/twilight/zen.linux-x86_64.tar.xz"
  let aarch64_url = $"https://github.com/zen-browser/desktop/releases/download/twilight/zen.linux-aarch64.tar.xz"
  let sources = {
	version: $tag
	x86_64-linux: {
	  url:  $x86_64_url
	  hash: (get_nix_hash $x86_64_url)
	}
	aarch64-linux: {
	  url: $aarch64_url
	  hash: (get_nix_hash $aarch64_url)
	}
  }

  if $sources.x86_64-linux.hash == $prev_sources.x86_64-linux.hash and $sources.aarch64-linux.hash == $prev_sources.aarch64-linux.hash {
	# everything up to date
	return {
	  prev_tag: $tag
	  new_tag: $tag
	}
  }

  echo $sources | save --force "sources.json"

  return {
    new_tag: $tag
    prev_tag: $prev_sources.version
  }
}
