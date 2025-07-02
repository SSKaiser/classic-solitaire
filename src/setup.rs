/* setup.rs */
/* Because registry API from kernel32 is awful */

use windows_registry::*;
use std::{env, fmt, array};

fn main() {
    let path = String::from(env::current_exe().unwrap().to_str().unwrap());
    let programpath = path.replace("\\", "_").replace("setup.exe", "sol.exe");
    let key = CURRENT_USER.create(format!("Console\\{}", programpath)).unwrap();

    key.set_string("FaceName", "Consolas");
    key.set_u32("FontFamily", 0x36);
    key.set_u32("FontSize", 0x140000);
    key.set_u32("FontWeight", 0x2bc);
    key.set_u32("LineWrap", 0);
    key.set_u32("ScreenBufferSize", 0x190050);
    key.set_u32("WindowSize", 0x190050);
}
