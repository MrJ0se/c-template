
import { C } from './deps.ts';
import { grantSource } from './grantSource.ts';


C.setCurrentTarget(C.hostPA);
const cmakeOpts:C.CMakeCrossOps = {
	win_runtimeReplace:C.RuntimeReplace.STATIC_X,
	apple_opts:{
		bundleGuiID:"com.ctemplate.test",
		sdkvMac:"14.0",
	}
};

export async function build (btype:C.BuildType):Promise<string> {
	const bsuffix = C.postfixFromBuildType(btype);

	const proot = C.projectRoot(`ctemplate-test`);
	const srcRoot = C.path.resolve(await grantSource('test'), 'test');
	const buildRoot = proot(C.Scope.TARGET, `build${bsuffix}`);

	C.AFS.mkdir(buildRoot);
	const args = [
		'-B', buildRoot,
		'-S', srcRoot,
		'rebuild',C.cmakeFlagFromBuildType(btype),
	];
	if (!(await C.CMake(args, cmakeOpts)).success)
		throw C.exitError("failed");

	let app = '';
	C.AFS.search(buildRoot, (path:string, isFile:boolean)=>{
		if (!isFile) return true;
		switch (C.path.basename(path)) {
		case 'test':
		case 'test.exe':
		case 'test.app':
			app = path;
		}
		return true;
	});
	return app;
}

console.log(await build(C.BuildType.DEBUG_COVERAGE));