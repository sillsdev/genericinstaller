# genericinstaller

WiX Reusable Installer Template.
Some installer work and ideas that are not product-specific.
See https://github.com/sillsdev/genericinstaller-sample for a sample use.

## How to use:
1)	Clone this repo as a submodule of your project.
2)	Copy Build*.bat, CommonVersion.cs, certpass.txt and Sample.(build|targets) from the sample project into your root project folder.
3)	Rename Sample.(build|targets) to <ProjectName>.build. Edit Build*.bat to reference the new <ProjectName>.build filename.
4)	Edit the <ProjectName>.(build|targets) file as follows:
	a.	Change all references to Sample to reference your project.
	b.	Edit the current release version number. The version number will always have four values, but do not edit the fourth one – it must be a “1” for the automatic version bumping to work.
	c.	Edit the Copyright Year and Manufacturer as needed.
	d.	Edit the CFG and Platform variables to match you build configuration.
	e.	Edit the CertPath to point to your code signing certificate file.
	f.	Generate a GUID for each new base release installer that is built. Note that each base installer must increment the third part of the version number. It is up to you to define the new number (VersionSeg3) and generate a product id GUID for it. Patch updates will automatically increment the fourth number.
	g.	If you are making a first build of a product that will be upgraded in the future, then generate a new UpgradeCodeGuid and a new CompGGS GUID. *Do not use the GUID's that come by default in this file.*
	h.	Check the value for “Installers.Base.Dir” – this is where the build files will be located relative to the location of this file.
	i.	You may need to extensively change the targets `Clean` and `CopyFilesToInstallation1` to work with your project, using the proper CFG and Platform properties.
	j.	The target `UpdateVersion` will need to set the correct version number in your AssemblyInfo file.
5)	Put your licensing information in the file `BaseInstallerBuild/TemplateLicense.htm`
6)	In the `resources` folder there are several graphics files used by the installer. Customize these as you wish but do not change the names or dimensions of the images, nor check them in to the genericinstaller repository (see TODO below).
7)	Open a command prompt and run the Build*Base.bat file to build your installer. The installer will be created in the BuildDir folder if all goes well.

## Work TODO:
 - Add a choose components window in MSI UI?
 - Add a choose components window in Bundle UI?
 - Move `resources` into the supermodule!

## Note
One of John Hatton’s big issues was that inevitably projects need to “downgrade” a file in the installation. Perhaps a new version of a dll was included, but it is unstable. How does the product installer move backwards to a more stable version? The current installer project under “Sample” can build a base installer that removes the “KeyPath” attributes from harvested files during the heat.exe process. This allows a later base installer to overwrite the higher versioned file with a lower versioned file. Patch files do NOT have this capability. The “KeyPath” hack results in an error during the patch creation process.
