import Version from '~/components/Version'

export default function Hero () {
  return <>
    <h1 className="hero">
      <span className="vite smooth">Vite</span> <span className="rails smooth">Rails</span>
    </h1>
    <Version/>
  </>
}
