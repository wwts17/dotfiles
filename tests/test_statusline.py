import importlib.util
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[1] / "antigravity/.gemini/antigravity-cli/statusline.py"
SPEC = importlib.util.spec_from_file_location("antigravity_statusline", SCRIPT)
statusline = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(statusline)


class SlidingTokensTest(unittest.TestCase):
    def test_counts_new_tokens_once_per_session(self):
        with tempfile.TemporaryDirectory() as directory:
            with patch.object(statusline, "SLIDING_CACHE_FILE", str(Path(directory) / "statusline.json")):
                with patch.object(statusline.time, "time", return_value=1000):
                    self.assertEqual(statusline.update_sliding_tokens("a", 100), (100, 100))
                    self.assertEqual(statusline.update_sliding_tokens("a", 100), (100, 100))
                    self.assertEqual(statusline.update_sliding_tokens("a", 150), (150, 150))
                    self.assertEqual(statusline.update_sliding_tokens("b", 40), (190, 190))
                with patch.object(statusline.time, "time", return_value=1061):
                    self.assertEqual(statusline.update_sliding_tokens("a", 160), (10, 200))

    def test_session_counter_reset_starts_new_sequence(self):
        with tempfile.TemporaryDirectory() as directory:
            with patch.object(statusline, "SLIDING_CACHE_FILE", str(Path(directory) / "statusline.json")):
                with patch.object(statusline.time, "time", return_value=1000):
                    statusline.update_sliding_tokens("a", 100)
                    self.assertEqual(statusline.update_sliding_tokens("a", 20), (120, 120))


if __name__ == "__main__":
    unittest.main()
