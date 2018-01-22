package codec;

import com.google.gson.JsonObject;

public class Processor {

	public static String parseInput(String input) {
		try {
			if (input == null || input.length() == 3)
				return "";
			
			JsonObject jsonObj = new JsonObject();
			jsonObj.addProperty("input", input);
			jsonObj.addProperty("time", System.currentTimeMillis());
			return jsonObj.toString();
		} catch(Exception e) {
			return "";
		}
	}
}
