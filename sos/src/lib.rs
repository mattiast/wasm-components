use wit_bindgen::generate;
use self::foo::bar::logger::log;

generate!({
    disable_run_ctors_once_workaround: true,
});

pub struct Thing;
impl Guest for Thing {
    fn sum_of_squares(x: u32, y: u32) -> u32 {
        let x2 = square(x);
        log(foo::bar::logger::Level::Info, &format!("Squared x: {}", x2));
        let y2 = square(y);
        log(foo::bar::logger::Level::Info, &format!("Squared y: {}", y2));
        x2 + y2
    }
}

export!(Thing);
