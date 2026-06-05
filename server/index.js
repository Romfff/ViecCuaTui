const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Chat endpoint to communicate with Gemini API (with robust model fallback)
app.post('/api/chat', async (req, res) => {
  const { message, dreamJob } = req.body;

  if (!message) {
    return res.status(400).json({ error: 'Message is required' });
  }

  const apiKey = process.env.GEMINI_API_KEY || process.env.OPENAI_API_KEY;
  if (!apiKey) {
    return res.status(500).json({ error: 'API key is not configured on server' });
  }

  // System Prompt guiding the AI to behave as a ViecCuaTui HR/Career Advisor
  const systemPrompt = `Bạn là HRBot - Trợ lý phân tích thị trường lao động và tư vấn nghề nghiệp của ứng dụng ViecCuaTui.
Hãy trả lời câu hỏi của sinh viên/ứng viên bằng tiếng Việt thật thân thiện, tự nhiên, chuyên nghiệp, truyền cảm hứng và hữu ích.
Hãy đưa ra những lời khuyên thực tế, trực diện và tránh viết quá chung chung.`;

  const contextMessage = dreamJob 
    ? `Định hướng nghề nghiệp của ứng viên này là: ${dreamJob}. Hãy lồng ghép thông tin tư vấn phù hợp với ngành này.`
    : `Ứng viên chưa cung cấp định hướng ngành cụ thể. Hãy đưa ra câu trả lời bao quát và khích lệ họ định hướng bản thân.`;

  // List of models to try in sequence in case of deprecations or high demand (503)
  const modelsToTry = [
    'gemini-flash-latest',
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-flash-lite-latest',
    'gemini-2.5-flash-lite',
    'gemini-2.0-flash-lite'
  ];

  let reply = null;
  let lastError = null;

  for (const model of modelsToTry) {
    try {
      console.log(`[HRBot] Attempting chat request with model: ${model}...`);
      const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
      
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          contents: [
            {
              role: 'user',
              parts: [
                { text: systemPrompt },
                { text: contextMessage },
                { text: `Câu hỏi của ứng viên: ${message}` }
              ]
            }
          ]
        })
      });

      if (response.ok) {
        const data = await response.json();
        if (data.candidates && data.candidates.length > 0 && data.candidates[0].content && data.candidates[0].content.parts.length > 0) {
          reply = data.candidates[0].content.parts[0].text;
          console.log(`[HRBot] Request succeeded using model: ${model}`);
          break; // Exit loop on success
        }
      } else {
        const errorText = await response.text();
        console.warn(`[HRBot] Model ${model} returned status ${response.status}: ${errorText}`);
        lastError = `Status ${response.status}: ${errorText}`;
      }
    } catch (err) {
      console.warn(`[HRBot] Error calling model ${model}:`, err.message);
      lastError = err.message;
    }
  }

  if (reply) {
    return res.json({ reply });
  } else {
    console.error('[HRBot] All models failed. Last error:', lastError);
    return res.status(503).json({ error: `Trợ lý AI hiện đang quá tải. Chi tiết lỗi: ${lastError}` });
  }
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'HRBot-proxy', engine: 'Gemini-Fallback' });
});

app.listen(PORT, () => {
  console.log(`HRBot Backend proxy (Gemini-Fallback) listening on port ${PORT}`);
});
