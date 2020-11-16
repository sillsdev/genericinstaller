# genericinstaller

WiX Reusable Installer Template.
Some installer work and ideas that are not product-specific.
See https://github.com/sillsdev/genericinstaller-sample for a sample use.

## How to use:
1)	Clone this repo as a submodule of your project.
2)	Copy Build*.bat, CommonVersion.cs, certpass.txt, and Sample.(build|targets), and SetVCVars.bat from the [sample project](https://github.com/sillsdev/genericinstaller-sample) into your root project folder. You may instead wish to put them in your project's build directory; if you do, you will need to update several relative paths.
3)	Rename Sample.(build|targets) to \<ProjectName\>.(build|targets). Edit Build*.bat to reference the new \<ProjectName\>.(build|targets) filename.
4)	Edit the \<ProjectName\>.(build|targets) file as follows:

	a.	Change all references to Sample to reference your project.

	b.	Edit the current release version number. The version number will always have four values, but do not edit the fourth one – it must be a “1” for the automatic version bumping to work.

	c.	Edit the Copyright Year and Manufacturer as needed.

	d.	Edit the CFG and Platform variables to match you build configuration.

	e.	Edit the CertPath to point to your code signing certificate file.

	f.	Generate a GUID for each new base release installer that is built. Note that each base installer must increment the third part of the version number. It is up to you to define the new number (VersionSeg3) and generate a product id GUID for it. Patch updates will automatically increment the fourth number (automatic version bumping is not fully implemented for MSBuild).

	g.	If you are making a first build of a product that will be upgraded in the future, then generate a new UpgradeCodeGuid and a new CompGGS GUID. If your product already has an UpgradeCode Guid that you used to build installers in the past, use that. **Do not use the GUID's that come by default in this file.**

	h.	Check the value for “Installers.Base.Dir” – this is where the build files will be located relative to the location of this file.

	i.	You may need to extensively change the targets `Clean` and `CopyFilesToInstallation1` to work with your project, using the proper CFG and Platform properties.

	j.	The target `UpdateVersion` will need to set the correct version number in your AssemblyInfo file.
5)	Put your licensing information in the file `resources\License.htm`, but do not check your changes in to the genericinstaller repository (see Working with Templates below).
6)	In the `resources` folder there are several graphics files used by the installer. Customize these as you wish but do not change the names or dimensions of the images, nor check them in to the genericinstaller repository (see Working with Templates below).
7)	Open a command prompt and run the Build*Base.bat file to build your installer. The installer will be created in the BuildDir folder in your repository if all goes well.

### Working with Templates:
This installer template is designed to be customizable with your own logos, license, etc., but customizing templates in shared locations is inconsiderate. Instead, your options include:
 - creating your own fork or branch of this repository (depending on whether you belong to the sillsdev organization)
 - keeping the customized items in your product's main repository and copying them on top of the template items as a build step (remember not to check them in)	

If you do not wish to use the build scripts from the sample project, simply:

* Clone this repo as a submodule of your project
* Download the Visual Studio redistributables (see the sample scripts)
* Ensure the WiX toolset is on your PATH
* (possible other steps)
* Call `BaseInstallerBuild\buildBaseInstaller.bat` and `CreateUpdatePatch\buildPatch.bat` passing the arguments listed at the beginnig of the respective scripts (see the end of Sample.(build|targets) for sample usage)

### Working with Templates:
This installer template is designed to be customizable with your own logos, license, etc., but customizing templates in shared locations is inconsiderate. Instead, your options include:
 - creating your own fork or branch of this repository (depending on whether you belong to the sillsdev organization)
 - keeping the customized items in your product's main repository and copying them on top of the template items as a build step (remember not to check them in--TODO: after the generic installer is more stable, .gitignore popularly-replaced files)

Popular Templates Include:
 - Icons under `resources`
 - `resources\License.htm`
 - `Common\Overrides.wxi` allows custom pre- and post-install actions as well as some custom paths
 - `Common\CustomFeatures.wxi` allows the inclusion of custom features for the user to be able to select

### Work TODO:
 - Add a choose components window in MSI UI?
 - Add a choose components window in Bundle UI?

#### Note
One of John Hatton’s big issues was that inevitably projects need to “downgrade” a file in the installation. Perhaps a new version of a dll was included, but it is unstable. How does the product installer move backwards to a more stable version? The base installer builder removes the “KeyPath” attributes from files harvested by heat.exe. This allows a later base installer to overwrite the higher versioned file with a lower versioned file. Patch files do NOT have this capability because this hack results in an error during the patch creation process.
