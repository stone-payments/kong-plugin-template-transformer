const versionRegex = /version = "(?<version>[\d.]*)-0"/;
const tagRegex = /tag = "v(?<version>[\d.]*)"/;

module.exports.readVersion = function (contents) {
  const { version } = contents.match(versionRegex).groups;
  return version;
};

module.exports.writeVersion = function (contents, version) {
  const versionReplacer = () => `version = "${version}-0"`;
  const tagReplacer = () => `tag = "v${version}"`;

  return contents
    .replace(versionRegex, versionReplacer)
    .replace(tagRegex, tagReplacer);
};
