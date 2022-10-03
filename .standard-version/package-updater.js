const capturingRegex = /VERSION = "(?<version>[\d.]*)"/;

module.exports.readVersion = function (contents) {
  const { version } = contents.match(capturingRegex).groups;
  return version;
};

module.exports.writeVersion = function (contents, version) {
  const replacer = () => `VERSION = "${version}"`;

  return contents.replace(capturingRegex, replacer);
};
