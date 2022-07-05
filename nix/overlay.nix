self: super: {
  pynixify = self.callPackage ./packages/pynixify { };

  types-aiofiles = self.callPackage ./packages/types-aiofiles { };

  types-setuptools = self.callPackage ./packages/types-setuptools { };
}
