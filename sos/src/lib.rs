use wit_bindgen::generate;

generate!({
    disable_run_ctors_once_workaround: true,
});

pub struct Thing;
impl Guest for Thing {
    fn sum_of_squares(x: u32, y: u32) -> u32 {
        let x2 = square(x);
        let y2 = square(y);
        x2 + y2
    }
}

export!(Thing);
