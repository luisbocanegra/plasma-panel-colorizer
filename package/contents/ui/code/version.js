/**
 * @enum
 */
const VersionDifference = {
  Lower: 0,
  Greater: 1,
  Equal: 2,
};

class Version {
  /**
   *
   * @param {string} version Version string e.g 1.2.3
   */
  constructor(version) {
    this._version = version;
  }

  get version() {
    return this._version;
  }

  /**
   * Compare two versions
   * @param {string} version1 Version 1
   * @param {string} version2 Version 2
   * @returns {VersionDifference}
   */
  compareVersions(version1, version2) {
    var v1 = version1.split("-")[0].split(".").map(Number);
    var v2 = version2.split("-")[0].split(".").map(Number);

    for (var i = 0; i < v1.length; ++i) {
      if (v2.length == i) {
        return VersionDifference.Greater;
      }
      if (v1[i] == v2[i]) {
        continue;
      } else if (v1[i] > v2[i]) {
        return VersionDifference.Greater;
      } else {
        return VersionDifference.Lower;
      }
    }

    if (version1.includes("-") && !version2.includes("-")) {
      return VersionDifference.Lower;
    } else if (!version1.includes("-") && version2.includes("-")) {
      return VersionDifference.Greater;
    } else if (version1.includes("-") && version2.includes("-")) {
      let suffix1 = version1.split("-")[1];
      let suffix2 = version2.split("-")[1];
      if (suffix1 > suffix2) {
        return VersionDifference.Greater;
      } else if (suffix1 < suffix2) {
        return VersionDifference.Lower;
      }
    }

    return v1.length != v2.length
      ? VersionDifference.Lower
      : VersionDifference.Equal;
  }

  /**
   * Compare version
   * @param {string} version2 Version to compare against
   * @returns {VersionDifference} Difference between versions
   */
  compare(version2) {
    return this.compareVersions(this._version, version2);
  }

  /**
   * Check if is Lower
   * @param {string} version2 Version to compare against
   * @returns {bool} Whether or not `version2` is Lower
   */
  isLowerThan(version2) {
    return VersionDifference.Lower === this.compare(version2);
  }

  /**
   * Check if is Greater
   * @param {string} version2 Version to compare against
   * @returns {bool} Whether or not `version2` is Greater
   */
  isGreaterThan(version2) {
    return VersionDifference.Greater === this.compare(version2);
  }

  /**
   * Check if is equal
   * @param {string} version2 Version to compare against
   * @returns {bool} Whether or not `version2` is equal
   */
  isEqual(version2) {
    return VersionDifference.Equal === this.compare(version2);
  }
}

// console.log(new Version("6.3.80").isLowerThan("6.2.0")); // false
// console.log(new Version("6.3.80").isGreaterThan("6.2.0")); // true
// console.log(new Version("6.3.80").isLowerThan("6.2.0")); // false
// console.log(new Version("6.3").isLowerThan("6.2.5")); // false
// console.log(new Version("6.1.5").isLowerThan("6.2.0")); // true
